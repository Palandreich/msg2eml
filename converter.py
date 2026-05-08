import email.utils
import mimetypes
from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path

import extract_msg


def convert(msg_path: str | Path) -> email.message.Message:
    msg = extract_msg.openMsg(str(msg_path))

    root = MIMEMultipart("mixed")

    if msg.subject:
        root["Subject"] = msg.subject
    if msg.sender:
        root["From"] = msg.sender
    if msg.to:
        root["To"] = msg.to
    if msg.cc:
        root["CC"] = msg.cc
    if msg.date:
        root["Date"] = email.utils.format_datetime(msg.date)
    root["Message-ID"] = email.utils.make_msgid()

    body = MIMEMultipart("alternative")
    if msg.body:
        body.attach(MIMEText(msg.body, "plain", "utf-8"))
    if msg.htmlBody:
        html = msg.htmlBody if isinstance(msg.htmlBody, str) else msg.htmlBody.decode("utf-8", errors="replace")
        body.attach(MIMEText(html, "html", "utf-8"))
    root.attach(body)

    for att in msg.attachments:
        data = att.data
        if data is None:
            continue
        mime_type, _ = mimetypes.guess_type(att.longFilename or att.shortFilename or "file")
        maintype, subtype = (mime_type or "application/octet-stream").split("/", 1)
        part = MIMEBase(maintype, subtype)
        part.set_payload(data)
        encoders.encode_base64(part)
        filename = att.longFilename or att.shortFilename or "attachment"
        part.add_header("Content-Disposition", "attachment", filename=filename)
        root.attach(part)

    msg.close()
    return root

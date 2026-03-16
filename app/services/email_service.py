import smtplib
import os
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

class EmailService:
    def __init__(self):
        self.smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        self.smtp_port = int(os.getenv("SMTP_PORT", "587"))
        self.smtp_user = os.getenv("SMTP_USER")
        self.smtp_password = os.getenv("SMTP_PASSWORD")
        
    def send_verification_email(self, recipient_email: str, code: str) -> bool:
        """
        Отправляет письмо с кодом подтверждения на указанный email
        Возвращает True при успехе, False при ошибке
        """
        if not self.smtp_user or not self.smtp_password:
            logger.error("SMTP credentials not configured")
            return False
            
        try:
            # Создаём сообщение [citation:2][citation:3]
            msg = MIMEMultipart("alternative")
            msg["From"] = self.smtp_user
            msg["To"] = recipient_email
            msg["Subject"] = "Код подтверждения"
            
            # Текстовая версия (plain text)
            text_part = MIMEText(
                f"Ваш код подтверждения: {code}\n\n"
                f"Если вы не запрашивали этот код, проигнорируйте письмо.",
                "plain"
            )
            
            # HTML-версия (более красивая) [citation:2][citation:3]
            html_content = f"""
            <html>
                <body style="font-family: Arial, sans-serif;">
                    <h2>Подтверждение действия</h2>
                    <p>Ваш код подтверждения:</p>
                    <h1 style="font-size: 32px; letter-spacing: 5px;">{code}</h1>
                    <p>Код действителен в течение 10 минут.</p>
                    <hr>
                    <p style="color: #666;">Если вы не запрашивали этот код, просто проигнорируйте письмо.</p>
                </body>
            </html>
            """
            html_part = MIMEText(html_content, "html")
            
            msg.attach(text_part)
            msg.attach(html_part)
            
            # Отправка через SMTP [citation:2][citation:3][citation:9]
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()  # TLS для порта 587 [citation:3]
                server.login(self.smtp_user, self.smtp_password)
                server.sendmail(self.smtp_user, recipient_email, msg.as_string())
                
            logger.info(f"Verification email sent to {recipient_email}")
            return True
            
        except smtplib.SMTPAuthenticationError as e:
            logger.error(f"SMTP authentication error: {e}")
            return False
        except smtplib.SMTPException as e:
            logger.error(f"SMTP error: {e}")
            return False
        except Exception as e:
            logger.error(f"Unexpected error sending email: {e}")
            return False

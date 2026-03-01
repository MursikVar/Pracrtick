from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

class Student(Base):
    __tablename__ = "student"

    login = Column(String(50), primary_key=True, index=True)
    user_name = Column(String(100))

    data = relationship("Data", back_populates="student", uselist=False)

class Data(Base):
    __tablename__ = "data"

    login = Column(String(50), ForeignKey("student.login"), primary_key=True)
    email_token = Column(String(255), nullable=True)
    google_token = Column(String(255), nullable=True)
    flutter_security_token = Column(String(255), nullable=True)
    yandex_token = Column(String(255), nullable=True)
    yandex_security_token = Column(String(255), nullable=True)
    password = Column(String(255), nullable=True)
    refresh_token = Column(String(255), nullable=True)

    student = relationship("Student", back_populates="data")

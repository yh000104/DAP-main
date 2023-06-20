from django.db import models
from django.contrib.auth.models import User

from djongo import models as djongo_models
from gridfs import GridFS
from django.http import HttpResponse

# Create your models here.


class Question(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    subject = models.CharField(max_length=200)
    content = models.TextField()
    modify_date = models.DateTimeField(null=True, blank=True)
    create_date = models.DateTimeField()

    def __str__(self):
        return self.subject


class Answer(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    content = models.TextField()
    modify_date = models.DateTimeField(null=True, blank=True)
    create_date = models.DateTimeField()


class Document(models.Model):
    uploader = models.CharField(max_length=100)
    description1 = models.CharField(max_length=255, blank=True)
    description2 = models.CharField(max_length=255, blank=True)
    description3 = models.CharField(max_length=255, blank=True)
    description4 = models.CharField(max_length=255, blank=True)
    description5 = models.CharField(max_length=255, blank=True)
    document = models.FileField(upload_to="documents/")
    uploaded_at = models.DateTimeField(auto_now_add=True)


class Autoupload(models.Model):
    user = models.CharField(max_length=100)
    file = models.FileField(upload_to="uploads/")
    create_date = models.DateTimeField(auto_now_add=True)
    AscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    SscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    PscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    LscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    SescorePer = models.DecimalField(max_digits=5, decimal_places=2)


class UploadFiles(models.Model):
    _id = models.AutoField(primary_key=True)
    users = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    txt_file = models.FileField(upload_to="uploads/")
    xlsx_file = models.FileField(upload_to="uploads/")
    created_at = models.DateTimeField()
    AscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    SscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    PscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    LscorePer = models.DecimalField(max_digits=5, decimal_places=2)
    SescorePer = models.DecimalField(max_digits=5, decimal_places=2)

    class Meta:
        db_table = "upload_files"

# class File(models.Model):
#     name = models.CharField(max_length=255)
#     file = models.FileField(upload_to='files/')

#     def download(self):
#         return self.file.url

class File(models.Model):
    name = models.CharField(max_length=255)
    file = djongo_models.FileField()

    def download_url(self):
        return '/download/{}/'.format(self.id)
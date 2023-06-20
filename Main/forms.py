from django import forms
from .models import Question, Answer, Document, Autoupload


class QuestionForm(forms.ModelForm):
    class Meta:
        model = Question  # 사용할 모델
        fields = ["subject", "content"]  # QuestionForm에서 사용할 Question 모델의 속성
        widgets = {
            "subject": forms.TextInput(attrs={"class": "form-control"}),
            "content": forms.Textarea(attrs={"class": "form-control", "rows": 10}),
        }
        labels = {
            "subject": "제목",
            "content": "내용",
        }


class AnswerForm(forms.ModelForm):
    class Meta:
        model = Answer
        fields = ["content"]
        labels = {
            "content": "답변내용",
        }


class DocumentForm(forms.ModelForm):
    class Meta:
        model = Document
        fields = [
            "uploader",
            "description1",
            "description2",
            "description3",
            "description4",
            "description5",
            "document",
        ]


class AutouploadForm(forms.ModelForm):
    class Meta:
        model = Autoupload
        exclude = ['create_date']
        fields = ["user", "file", "create_date", "AscorePer", "SscorePer", "PscorePer", "LscorePer", "SescorePer"]

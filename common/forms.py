from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User


class UserForm(UserCreationForm):
    email = forms.EmailField(label="이메일")
    agree = forms.BooleanField(label="약관에 동의해주세요.")

    class Meta:
        model = User
        fields = ("username", "password1", "password2", "email")

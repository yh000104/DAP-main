from django.shortcuts import render, get_object_or_404, redirect

from .models import Question, Answer, Document, Autoupload, UploadFiles
from .forms import QuestionForm, AnswerForm, DocumentForm, AutouploadForm

from django.utils import timezone
from django.http import HttpResponseNotAllowed
from django.core.paginator import Paginator
from django.contrib.auth.decorators import login_required
from django.contrib import messages

from django.conf import settings
from django.core.files.storage import FileSystemStorage

from django.http import HttpResponse, Http404
import subprocess
import os
import datetime
import time
from django.core.files import File

from django.conf import settings
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from bson import ObjectId
import gridfs
import pymongo
from .utils import score

# Create your views here.


def board(request):
    page = request.GET.get("page", "1")  # 페이지
    question_list = Question.objects.order_by("-create_date")
    paginator = Paginator(question_list, 10)  # 페이지당 10개씩 보여주기
    page_obj = paginator.get_page(page)
    context = {"question_list": page_obj}
    return render(request, "question_list.html", context)


def detail(request, question_id):
    question = Question.objects.get(id=question_id)
    context = {"question": question}
    return render(request, "question_detail.html", context)


@login_required(login_url="common:login")
def answer_create(request, question_id):
    question = get_object_or_404(Question, pk=question_id)

    if request.method == "POST":
        form = AnswerForm(request.POST)
        if form.is_valid():
            answer = form.save(commit=False)
            answer.author = request.user  # author 속성에 로그인 계정 저장
            answer.create_date = timezone.now()
            answer.question = question
            answer.save()
            return redirect("detail", question_id=question.id)
        else:
            form = AnswerForm()
        context = {"question": question, "form": form}
        return render(request, "question_detail.html", context)


@login_required(login_url="common:login")
def question_create(request):
    if request.method == "POST":
        form = QuestionForm(request.POST)
        if form.is_valid():
            question = form.save(commit=False)
            question.author = request.user  # author 속성에 로그인 계정 저장
            question.create_date = timezone.now()
            question.save()
            return redirect("index")
    else:
        form = QuestionForm()
    context = {"form": form}
    return render(request, "question_form.html", context)


@login_required(login_url="common:login")
def question_modify(request, question_id):
    question = get_object_or_404(Question, pk=question_id)
    if request.user != question.author:
        messages.error(request, "수정권한이 없습니다")
        return redirect("detail", question_id=question.id)
    if request.method == "POST":
        form = QuestionForm(request.POST, instance=question)
        if form.is_valid():
            question = form.save(commit=False)
            question.modify_date = timezone.now()  # 수정일시 저장
            question.save()
            return redirect("detail", question_id=question.id)
    else:
        form = QuestionForm(instance=question)
    context = {"form": form}
    return render(request, "question_form.html", context)


@login_required(login_url="common:login")
def question_delete(request, question_id):
    question = get_object_or_404(Question, pk=question_id)
    if request.user != question.author:
        messages.error(request, "삭제권한이 없습니다")
        return redirect("detail", question_id=question.id)
    question.delete()
    return redirect("index")


@login_required(login_url="common:login")
def answer_modify(request, answer_id):
    answer = get_object_or_404(Answer, pk=answer_id)
    if request.user != answer.author:
        messages.error(request, "수정권한이 없습니다")
        return redirect("detail", question_id=answer.question.id)
    if request.method == "POST":
        form = AnswerForm(request.POST, instance=answer)
        if form.is_valid():
            answer = form.save(commit=False)
            answer.modify_date = timezone.now()
            answer.save()
            return redirect("detail", question_id=answer.question.id)
    else:
        form = AnswerForm(instance=answer)
    context = {"answer": answer, "form": form}
    return render(request, "answer_form.html", context)


@login_required(login_url="common:login")
def answer_delete(request, answer_id):
    answer = get_object_or_404(Answer, pk=answer_id)
    if request.user != answer.author:
        messages.error(request, "삭제권한이 없습니다")
    else:
        answer.delete()
    return redirect("detail", question_id=answer.question.id)


def simple_upload(request):
    if request.method == "POST" and request.FILES["myfile"]:
        myfile = request.FILES["myfile"]
        fs = FileSystemStorage()
        filename = fs.save(myfile.name, myfile)
        uploaded_file_url = fs.url(filename)
        return render(
            request, "simple_upload.html", {"uploaded_file_url": uploaded_file_url}
        )
    return render(request, "simple_upload.html")


def download(request):
    return render(request, "download.html")


# 수동 업로드 & 파일 관리


@login_required(login_url="common:login")
def model_form(request):
    documents = Document.objects.all()
    return render(
        request,
        "model_form.html",
        {
            "documents": documents,
        },
    )


@login_required(login_url="common:login")
def model_form_upload(request):
    if request.method == "POST":
        form = DocumentForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return redirect("model_form_upload")
    else:
        form = DocumentForm()
    return render(
        request,
        "model_form_upload.html",
        {
            "form": form,
        },
    )


def model_form_delete(request, file_id):
    model_delete = Document.objects.get(pk=file_id)
    model_delete.document.delete()  # 파일 삭제
    model_delete.delete()  # 모델 삭제
    return redirect("model_form")


# 진욱이 작업


def index(request):
    return render(request, "home.html")


def diagnosis(request):
    return render(request, "diagnosis.html")


def winsow_diagnosis(request):
    return render(request, "window_diagnosis.html")


def linux_diagnosis(request):
    return render(request, "linux_diagnosis.html")


# 스크립트 페이지


def run_script(request):
    subprocess.call(["python", "static/Syne.py"])
    return HttpResponse("Script executed successfully.")


@login_required(login_url="common:login")
def connect(request):
    return render(request, "connect.html")


def upload_report(request):
    user = request.user
    user_name = request.user.username  # 현재 로그인한 유저의 이름
    date = datetime.datetime.now().strftime("%Y-%m-%d")  # 현재 날짜
    folder_path = os.path.join(settings.MEDIA_ROOT, "newfile", user_name, date)
    os.makedirs(folder_path, exist_ok=True)
    '''os.environ["FOLDER_PATH"] = folder_path'''

    AscorePer, SscorePer, PscorePer, LscorePer, SescorePer = score.return_score(folder_path)

    # 파일 경로를 설정합니다.
    file_path = os.path.join(folder_path, "txt", "report.txt")  # 생성된 파일의 경로
    file_name = f"{user_name}_{date}_report.txt"  # 생성할 파일의 이름

    # 파일이 생성될 때까지 기다리는 함수
    def wait_for_file(file_path, timeout=20):
        start_time = time.time()
        while not os.path.exists(file_path):
            elapsed_time = time.time() - start_time
            if elapsed_time > timeout:
                raise TimeoutError(
                    f"File {file_path} was not created within the timeout."
                )
            time.sleep(0.1)

    wait_for_file(file_path)  # 파일이 생성될 때까지 대기합니다.

    file_obj = File(open(file_path, "rb"))

    # 모델 인스턴스를 생성하고 File 객체를 모델 필드에 할당합니다.
    my_model = Autoupload(user=user_name)
    my_model.AscorePer = AscorePer
    my_model.SscorePer = SscorePer
    my_model.PscorePer = PscorePer
    my_model.LscorePer = LscorePer
    my_model.SescorePer = SescorePer
    my_model.file.save(file_name, file_obj, save=True)
    print(AscorePer, SscorePer, PscorePer, LscorePer, SescorePer)
    my_model.save()

def connect_user(request):
    if request.method == "POST":
        client_IP = request.POST.get("client_IP")
        client_name = request.POST.get("client_name")
        client_password = request.POST.get("client_password")

        user_name = request.user.username  # 현재 로그인한 유저의 이름
        date = datetime.datetime.now().strftime("%Y-%m-%d")  # 현재 날짜
        form = AutouploadForm(request.POST)

        # 폴더 경로를 생성합니다.
        folder_path = os.path.join(settings.MEDIA_ROOT, "newfile", user_name, date)
        os.makedirs(folder_path, exist_ok=True)
        os.environ["FOLDER_PATH"] = folder_path

        subprocess.call(
            [
                "python",
                "static/Syne.py",
                client_IP,
                client_name,
                client_password,
            ]
        )

        context = {
            "user_id": request.POST.get("user_id"),
            "agree": request.POST.get("agree"),
            "client_IP": request.POST.get("client_IP"),
            "client_name": request.POST.get("client_name"),
            "client_password": request.POST.get("client_password"),
            "form": form,
        }
        upload_report(request)
    return render(request, "connect_user.html", context)


@login_required(login_url="common:login")
def connect_list(request):
    items = Autoupload.objects.all()
    return render(
        request,
        "connect_list.html",
        {
            "items": items,
        },
    )


def connect_list_delete(request, file_id):
    list_delete = Autoupload.objects.get(pk=file_id)

    # Close the File object and delete the file.
    list_delete.file.close()
    file_path = os.path.join(settings.MEDIA_ROOT, list_delete.file.name)

    try:
        if os.path.isfile(file_path):
            os.remove(file_path)
    except PermissionError as e:
        print(f"Error: {e}")

    # Sleep for 3 seconds before attempting to delete the model.
    time.sleep(3)
    list_delete.delete()  # 모델 삭제

    return redirect("connect_list")

def upload_files_delete(request, file_id):
    list_delete = UploadFiles.objects.get(pk=file_id)
    list_delete.delete()  # 모델 삭제

    return redirect("pyqt5")


def pyqt5(request):
    items = UploadFiles.objects.all()
    return render(request, "pyqt5.html", {"items": items})

def download_file(request, file_id):
    # MongoDB 연결
    client = pymongo.MongoClient('mongodb+srv://admin:admin@cluster0.qs8u6xx.mongodb.net/')
    db = client['dap-test1']
    fs = gridfs.GridFS(db)

    try:
        # ObjectId 변환
        obj_id = ObjectId(file_id)

        # 파일 가져오기
        file_obj = fs.get(obj_id)

        # 다운로드할 파일이 존재하는 경우
        response = HttpResponse(file_obj.read(), content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        response['Content-Disposition'] = 'attachment; filename=%s' % file_obj.filename
        return response

    except gridfs.errors.NoFile:
        # 파일이 존재하지 않는 경우
        raise Http404("The requested file does not exist.")
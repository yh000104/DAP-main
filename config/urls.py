from django.contrib import admin
from django.urls import path, include

from Main import views

from django.conf import settings
from django.conf.urls.static import static

# from ..Main.views import download_file

urlpatterns = [
    path("admin/", admin.site.urls),
    # 메인화면
    path("", views.index, name="index"),
    path("board/", views.board, name="board"),
    path("<int:question_id>/", views.detail, name="detail"),
    path("answer/create/<int:question_id>/", views.answer_create, name="answer_create"),
    path("question/create/", views.question_create, name="question_create"),
    path("common/", include("common.urls")),
    path("diagnosis/", views.diagnosis, name="diagnosis"),
    # 진단 다운로드 페이지
    path("diagnosis/window", views.winsow_diagnosis, name="window_diagnosis"),
    path("diagnosis/linux", views.linux_diagnosis, name="linux_diagnosis"),
    # 질문답변 수정 및 삭제
    path(
        "question/modify/<int:question_id>/",
        views.question_modify,
        name="question_modify",
    ),
    path(
        "question/delete/<int:question_id>/",
        views.question_delete,
        name="question_delete",
    ),
    path("answer/modify/<int:answer_id>/", views.answer_modify, name="answer_modify"),
    path("answer/delete/<int:answer_id>/", views.answer_delete, name="answer_delete"),
    # 수동 업로드 페이지
    path("model_form/", views.model_form, name="model_form"),
    path("model_form_upload/", views.model_form_upload, name="model_form_upload"),
    path(
        "model_form_delete/<int:file_id>/",
        views.model_form_delete,
        name="model_form_delete",
    ),
    # 스크립트 실행
    path("connect/", views.connect, name="connect"),
    path("run_script/", views.run_script, name="run_script"),
    path("connect_user/", views.connect_user, name="connect_user"),
    path("connect_list/", views.connect_list, name="connect_list"),
    path(
        "connect_list_delete/<int:file_id>/",
        views.connect_list_delete,
        name="connect_list_delete",
    ),
    path("pyqt5/", views.pyqt5, name="pyqt5"),
    path('download/<str:file_id>/', views.download_file, name='download_file'),
    path(
        "upload_files_delete/<int:file_id>/",
        views.upload_files_delete,
        name="upload_files_delete",
    ),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

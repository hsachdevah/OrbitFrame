import functions_framework

@functions_framework.http
def hello_scheduled(request):
    print("I was triggered by a schedule!")
    return 'OK', 200

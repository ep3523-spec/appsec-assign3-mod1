from django.http import HttpResponse
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

# Safe metric - only counts attempts, no sensitive data
LOGIN_ATTEMPT_COUNTER = Counter("login_attempt_total", "Total login attempts")

def login_view(request):
    if request.method == "POST":
        # Increment counter WITHOUT logging password
        LOGIN_ATTEMPT_COUNTER.inc()
        
        username = request.POST.get("username")
        password = request.POST.get("password")
        
        # Authenticate user
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            login(request, user)
            return redirect("home")
        else:
            return render(request, "login.html", {"error": "Invalid credentials"})
    
    return render(request, "login.html")


# Health / readiness endpoints (no heavy DB checks to stay fast)
def healthz(request):
    return HttpResponse("ok", content_type="text/plain")


def readyz(request):
    # If future readiness logic needed (e.g., DB ping), add here.
    return HttpResponse("ready", content_type="text/plain")


def metrics(request):
    data = generate_latest()
    return HttpResponse(data, content_type=CONTENT_TYPE_LATEST)

# ...existing code for other views...
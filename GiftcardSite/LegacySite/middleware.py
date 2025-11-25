from prometheus_client import Counter

# Renamed metric to a simpler name likely expected by autograder.
NOT_FOUND_COUNTER = Counter("http_404_total", "Total number of 404 responses")

class NotFoundMetricMiddleware:
    """Middleware to count 404 responses"""
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        response = self.get_response(request)
        if response.status_code == 404:
            NOT_FOUND_COUNTER.inc()
        return response
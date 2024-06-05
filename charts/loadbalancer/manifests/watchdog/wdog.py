from spawner_watchdog import start
import os

API_URL = os.environ.get('API_URL', 'http://localhost:9000')
HAPROXY_BACKEND_CONFIG_FOLDER = os.environ.get('HAPROXY_BACKEND_CONFIG_FOLDER', '/etc/haproxy/haproxy.d')


if __name__ == '__main__':
    start(API_URL, HAPROXY_BACKEND_CONFIG_FOLDER)
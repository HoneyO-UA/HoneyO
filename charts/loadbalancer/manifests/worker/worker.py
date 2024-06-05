from spawner_workers import HAProxy
import asyncio
import os

HAPROXY_RUNTIME_SOCKET = os.environ.get('HAPROXY_RUNTIME_SOCKET', '/var/run/haproxy.sock')
HAPROXY_BACKEND_CONFIG_FOLDER = os.environ.get('HAPROXY_BACKEND_CONFIG_FOLDER', '/etc/haproxy/haproxy.d')
API_URL = os.environ.get("API_URL", "http://127.0.0.1:9000")
RABBITMQ_URL = os.environ.get("RABBITMQ_URL", "amqp://guest:guest@localhost/")
BACKEND_TEMPLATE_FILE = os.environ.get("BACKEND_TEMPLATE_FILE", "backend.tmpl")
SLACK_BOT_TOKEN = os.environ.get("SLACK_BOT_TOKEN")

if __name__ == '__main__':
    worker = HAProxy(HAPROXY_RUNTIME_SOCKET, HAPROXY_BACKEND_CONFIG_FOLDER, API_URL, RABBITMQ_URL,
                     BACKEND_TEMPLATE_FILE, SLACK_BOT_TOKEN)
    asyncio.run(worker.start())

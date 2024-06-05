import argparse
import uuid
from binascii import hexlify


def main(args):
    with open(args.template) as fp:
        backend_template = fp.read()

    for i in range(args.number):
        id_ = uuid.uuid4().hex
        data = {"backend": id_, "server": f"server_{id_}", "addr": "127.0.0.1:9999"}
        config = backend_template.format(**data)
        filename = id_

        if args.encode and False:
            server_config = config.split('\n')[-2].strip()
            if not server_config.startswith('server'):
                print('Invalid server config. SKIPPING!')
                continue

            encoded_config = hexlify(server_config.encode()).decode()
            filename = f'{filename}-{encoded_config}'

        with open(f'{args.path}/{filename}.cfg', 'w') as fp:
            fp.write(config)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Backend entries script creation (HA proxy reload necessary)")
    parser.add_argument('-t', '--template', type=str, default='backend.tmpl',
                        help='Path to the backend template file (default: ./backend.tmpl)')

    parser.add_argument('-n', '--number', type=int, default=10000,
                        help='Number of backend entries to create in the haproxy (default: 10000)')

    parser.add_argument('-e', '--encode', type=bool, default=False,
                        help='Encode the file contents in the filename (default: False)')

    parser.add_argument('-p', '--path', type=str, default='/etc/haproxy/haproxy.d',
                        help='Path to the config files (default=/etc/haproxy/haproxy.d)')

    main(parser.parse_args())


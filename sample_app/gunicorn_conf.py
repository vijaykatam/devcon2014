# -*- coding: utf-8 -*-

bind = '0.0.0.0:8000'
secure_scheme_headers = {'X-FORWARDED-PROTOCOL': 'https', 'X-FORWARDED-SSL': 'on'}
timeout = 120
forwarded_allow_ips = '*'
proc_name = 'sample_app'
errorlog = '/var/log/gunicorn/sample_app_error.log'

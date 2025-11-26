from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import json
from ansible.module_utils.urls import open_url

class CortexXSOARClient:
    def __init__(self, module):
        self.module = module
        self.base_url = module.params['url']
        self.api_key = module.params['api_key']
        self.account = module.params.get('account')
        self.validate_certs = module.params['validate_certs']
        self.timeout = module.params.get('timeout', 30)
        self.headers = {
            "Authorization": f"{self.api_key}",
            "Accept": "application/json",
            "Content-Type": "application/json"
        }

    def get_url(self, url_suffix):
        if self.account:
            return f'{self.base_url}/acc_{self.account}/{url_suffix}'
        return f'{self.base_url}/{url_suffix}'

    def send_request(self, method, url_suffix, data=None):
        url = self.get_url(url_suffix)
        json_data = json.dumps(data, ensure_ascii=False) if data else None
        
        try:
            response = open_url(url, method=method, headers=self.headers, data=json_data, validate_certs=self.validate_certs, timeout=self.timeout)
            if response.getcode() == 204:
                return None
            return json.loads(response.read())
        except Exception as e:
            # In a real refactor, we might want to let the module handle the error or fail here.
            # For now, we'll raise it to be caught by the module's try/except blocks if they want,
            # or we can fail_json directly if we want to enforce standard error handling.
            raise e

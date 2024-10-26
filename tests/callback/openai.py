# -*- coding: utf-8 -*-
# Copyright (c) 2023 Sagi Shnaidman <sshnaidm@gmail.com>
# GNU General Public License v3.0+ (see LICENSES/GPL-3.0-or-later.txt or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type


DOCUMENTATION = '''
    name: openai
    type: notification
    short_description: Analyzes Ansible tasks and playbooks with OpenAI GPT via OpenRouter
    description:
      - Analyzes Ansible tasks and playbooks with OpenAI GPT using OpenRouter as a proxy.
      - Prints explanations for the tasks and playbooks
      - Suggests improvements to the tasks and playbooks if any
    requirements:
      - enable in configuration - see examples section below for details.

    options:
      openrouter_api_key:
        description: OpenRouter API key
        env:
          - name: OPENROUTER_API_KEY
        ini:
          - section: callback_openai
            key: openrouter_api_key
      openai_model:
        description: OpenAI model (passed through OpenRouter)
        default: openai/gpt-3.5-turbo
        env:
          - name: OPENAI_MODEL
        ini:
          - section: callback_openai
            key: openai_model
      temperature_ai:
        description: Temperature for OpenAI GPT
          - 'https://platform.openai.com/docs/api-reference/completions/create#completions/create-temperature'
        default: 0.4
        env:
          - name: OPENAI_TEMPERATURE
        ini:
          - section: callback_openai
            key: openai_temperature
      tokens_ai:
        description: Number of tokens for OpenAI GPT
          - 'https://platform.openai.com/docs/api-reference/completions/create#completions/create-max_tokens'
        env:
          - name: OPENAI_TOKENS
        ini:
          - section: callback_openai
            key: openai_tokens
      openrouter_base_url:
        description: Base URL for OpenRouter API
        default: https://openrouter.ai/api/v1
        env:
          - name: OPENROUTER_BASE_URL
        ini:
          - section: callback_openai
            key: openrouter_base_url
      http_referer:
        description: Optional HTTP referer for OpenRouter, used for rankings
        env:
          - name: HTTP_REFERER
        ini:
          - section: callback_openai
            key: http_referer
      app_name:
        description: Optional application name for OpenRouter, used for rankings
        env:
          - name: APP_NAME
        ini:
          - section: callback_openai
            key: app_name
'''


import json  # noqa: E402
import yaml  # noqa: E402
try:
    from openai import OpenAI  # noqa: E402
    HAS_OPENAI = True
except ImportError:
    HAS_OPENAI = False

from ansible.plugins.callback import CallbackBase  # noqa: E402
from ansible.module_utils._text import to_text  # noqa: E402
from os import getenv


def get_openai_description(
        task_text=None,
        play_text=None,
        temperature_ai=None,
        tokens_ai=None,
        openrouter_api_key=None,
        model=None,
        openrouter_base_url=None,
        http_referer=None,
        app_name=None):
    if not HAS_OPENAI:
        return to_text("Please install openai python library to use this plugin")

    if not openrouter_api_key:
        return to_text("Please set OPENROUTER_API_KEY environment variable for GPT plugin to work. "
                       "Either in the environment OPENROUTER_API_KEY or in the config file.")

    client = OpenAI(
        api_key=openrouter_api_key,
        base_url=openrouter_base_url
    )

    extra_headers = {}
    if http_referer:
        extra_headers["HTTP-Referer"] = http_referer
    if app_name:
        extra_headers["X-Title"] = app_name

    if task_text:
        prompt = ("I want you to act as a code reviewer for Ansible, and provide feedback on potential"
                  "improvements to the code. As a reviewer, I expect you to analyze the code for best practices,"
                  "identify any potential issues or inefficiencies,"
                  "and suggest improvements to optimize performance and readability. Here is my code:"
                  f"\n```\n{task_text}```\n"
                  "Explain briefly what current Ansible code does, don't print the code itself."
                  "If you have any significant improvements for this code, "
                  "please suggest them as well, print them after word 'Suggestions:'"
                  "If you don't have any suggestions, print 'No suggestions' only.")
    elif play_text:
        prompt = ("I want you to act as a code reviewer for Ansible, and provide feedback on potential"
                  "improvements to the code. As a reviewer, I expect you to analyze the code for best practices,"
                  "identify any potential issues or inefficiencies,"
                  "and suggest improvements to optimize performance and readability. "
                  "Focus on the whole purpose of the playbook and what it does, rather than on each one of tasks."
                  "Here is my code:"
                  f"\n```\n{play_text}```\n"
                  "Explain briefly what current Ansible playbook does, don't print the code itself."
                  "If you have any significant improvements for this code, "
                  "please suggest them as well, print them after word 'Suggestions:'"
                  "If you don't have any suggestions, print 'No suggestions' only.")

    messages=[
        {"role": "system",
                 "content": "You are a helpful assistant and Ansible expert. :)"},
        {"role": "assistant", "content": ""},
        {"role": "user", "content": prompt},
    ]

    try:
        completion = client.chat.completions.create(
            extra_headers=extra_headers,
            model=model,
            messages=messages,
            temperature=float(temperature_ai) if temperature_ai else None,
            max_tokens=int(tokens_ai) if tokens_ai else None,
        )
        answer = completion.choices[0].message.content.strip()
    except Exception as e:
        return to_text(f"Error: {e}")

    return to_text(answer)


class CallbackModule(CallbackBase):

    CALLBACK_VERSION = 1.0
    CALLBACK_TYPE = 'aggregate'
    CALLBACK_NAME = 'sshnaidm.openai.openai'
    CALLBACK_NEEDS_WHITELIST = True

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.model = None
        self.temperature_ai = None
        self.tokens_ai = None
        self.openrouter_api_key = None
        self.openrouter_base_url = None
        self.http_referer = None
        self.app_name = None
        self.kwargs = None

    def set_options(self, task_keys=None, var_options=None, direct=None):
        super(CallbackModule, self).set_options(task_keys=task_keys,
                                                var_options=var_options,
                                                direct=direct)
        self.model = self.get_option('openai_model')
        self.temperature_ai = self.get_option('temperature_ai')
        self.tokens_ai = self.get_option('tokens_ai')
        self.openrouter_api_key = self.get_option('openrouter_api_key')
        self.openrouter_base_url = self.get_option('openrouter_base_url')
        self.http_referer = self.get_option('http_referer')
        self.app_name = self.get_option('app_name')
        self.kwargs = {
            'model': self.model,
            'openrouter_api_key': self.openrouter_api_key,
            'temperature_ai': self.temperature_ai,
            'tokens_ai': self.tokens_ai,
            'openrouter_base_url': self.openrouter_base_url,
            'http_referer': self.http_referer,
            'app_name': self.app_name,
        }

    def v2_playbook_on_task_start(self, task, is_conditional):
        task_text = yaml.dump([json.loads(json.dumps(task._ds))])
        kwargs = {'task_text': task_text, **self.kwargs}
        print(f"Explanation: \n{get_openai_description(**kwargs)}")

    def v2_playbook_on_play_start(self, play):
        play_text = yaml.dump(json.loads(json.dumps(play.get_ds())))
        kwargs = {'play_text': play_text, **self.kwargs}
        print(f"Explanation: \n{get_openai_description(**kwargs)}")

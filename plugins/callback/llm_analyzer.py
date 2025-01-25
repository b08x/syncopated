# -*- coding: utf-8 -*-
# Copyright (c) 2023 Sagi Shnaidman <sshnaidm@gmail.com>
# GNU General Public License v3.0+ (see LICENSES/GPL-3.0-or-later.txt or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
    name: llm_analyzer
    type: notification
    short_description: Analyzes Ansible tasks and playbooks with various AI models
    description:
      - Analyzes Ansible tasks and playbooks using different AI providers
      - Prints explanations for the tasks and playbooks
      - Saves explanations to markdown files in llm_analysis directory
      - Suggests improvements to the tasks and playbooks if any
    requirements:
      - enable in configuration - see examples section below for details
      - install required provider libraries (openai, google.generativeai, etc.)

    options:
      provider:
        description: AI provider to use
        choices: ['openai', 'gemini', 'groq', 'openrouter', 'cohere', 'anthropic']
        default: openai
        env:
          - name: AI_PROVIDER
        ini:
          - section: callback_llm_analyzer
            key: provider
      api_key:
        description: API key for the chosen provider
        env:
          - name: OPENAI_API_KEY
          - name: GEMINI_API_KEY
          - name: GROQ_API_KEY
          - name: OPENROUTER_API_KEY
          - name: COHERE_API_KEY
          - name: ANTHROPIC_API_KEY
        ini:
          - section: callback_llm_analyzer
            key: api_key
      model:
        description: Model to use for the chosen provider
        default: gpt-4
        env:
          - name: AI_MODEL
        ini:
          - section: callback_llm_analyzer
            key: model
      temperature:
        description: Temperature for AI response
        default: 0.4
        env:
          - name: AI_TEMPERATURE
        ini:
          - section: callback_llm_analyzer
            key: temperature
      max_tokens:
        description: Maximum tokens for AI response
        env:
          - name: AI_MAX_TOKENS
        ini:
          - section: callback_llm_analyzer
            key: max_tokens
'''

import os
import json
import yaml
import datetime
from pathlib import Path
from typing import Optional, Dict, Any
from ansible.plugins.callback import CallbackBase
from ansible.module_utils._text import to_text

# Provider-specific imports
AVAILABLE_PROVIDERS = {}

try:
    import openai
    AVAILABLE_PROVIDERS['openai'] = True
except ImportError:
    AVAILABLE_PROVIDERS['openai'] = False

try:
    import google.generativeai as genai
    AVAILABLE_PROVIDERS['gemini'] = True
except ImportError:
    AVAILABLE_PROVIDERS['gemini'] = False

try:
    import groq
    AVAILABLE_PROVIDERS['groq'] = True
except ImportError:
    AVAILABLE_PROVIDERS['groq'] = False

try:
    import cohere
    AVAILABLE_PROVIDERS['cohere'] = True
except ImportError:
    AVAILABLE_PROVIDERS['cohere'] = False

try:
    import anthropic
    AVAILABLE_PROVIDERS['anthropic'] = True
except ImportError:
    AVAILABLE_PROVIDERS['anthropic'] = False

# OpenRouter uses OpenAI's client
AVAILABLE_PROVIDERS['openrouter'] = AVAILABLE_PROVIDERS['openai']

class AIProvider:
    def __init__(self, provider: str, api_key: str, model: str, temperature: float, max_tokens: Optional[int]):
        self.provider = provider
        self.api_key = api_key
        self.model = model
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.client = None
        self._setup_client()

    def _setup_client(self):
        if self.provider == 'openai':
            openai.api_key = self.api_key
            self.client = openai.ChatCompletion
        elif self.provider == 'openrouter':
            openai.base_url = "https://openrouter.ai/api/v1"
            openai.api_key = self.api_key
            self.client = openai.ChatCompletion
        elif self.provider == 'gemini':
            genai.configure(api_key=self.api_key)
            self.client = genai.GenerativeModel(self.model)
        elif self.provider == 'groq':
            self.client = groq.Client(api_key=self.api_key)
        elif self.provider == 'cohere':
            self.client = cohere.ClientV2(api_key=self.api_key)
        elif self.provider == 'anthropic':
            self.client = anthropic.Anthropic(api_key=self.api_key)

    def _create_prompt(self, task_text: Optional[str] = None, play_text: Optional[str] = None) -> str:
        if task_text:
            return ("Review the following Ansible code, "
                   "focusing on best practices, potential issues, "
                   "inefficiencies, and improvements for performance and readability:"
                   f"\n```\n{task_text}```\n"
                   "Explain its function. Suggestions:")
        elif play_text:
            return ("Review the following Ansible playbook, "
                   "focusing on overall purpose and effectiveness, not individual tasks:"
                   f"\n```\n{play_text}```\n"
                   "Briefly explain the playbook's function. "
                   "Then, suggest significant improvements (if any) after the word 'Suggestions:'. "
                   "If none, print 'No suggestions'.")
        return ""

    def get_description(self, task_text: Optional[str] = None, play_text: Optional[str] = None) -> str:
        if not AVAILABLE_PROVIDERS.get(self.provider):
            return to_text(f"Please install the required library for {self.provider}")
        
        if not self.api_key:
            return to_text(f"Please set the API key for {self.provider}")

        prompt = self._create_prompt(task_text, play_text)
        
        try:
            if self.provider in ['openai', 'openrouter']:
                kwargs = {
                    'model': self.model,
                    'messages': [
                        {"role": "system", "content": "You are a helpful assistant and Ansible expert."},
                        {"role": "user", "content": prompt}
                    ]
                }
                if self.temperature is not None:
                    kwargs['temperature'] = self.temperature
                if self.max_tokens:
                    kwargs['max_tokens'] = self.max_tokens
                
                response = self.client.create(**kwargs)
                return to_text(response.choices[0].message.content.strip())

            elif self.provider == 'gemini':
                response = self.client.generate_content(prompt)
                return to_text(response.text.strip())

            elif self.provider == 'groq':
                completion = self.client.chat.completions.create(
                    model=self.model,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=self.temperature if self.temperature is not None else 0.4,
                    max_tokens=self.max_tokens if self.max_tokens else None
                )
                return to_text(completion.choices[0].message.content.strip())

            elif self.provider == 'cohere':
                response = self.client.generate(
                    prompt=prompt,
                    model=self.model,
                    temperature=self.temperature if self.temperature is not None else 0.4,
                    max_tokens=self.max_tokens if self.max_tokens else None
                )
                return to_text(response.generations[0].text.strip())
            
            elif self.provider == 'anthropic':
                message = self.client.messages.create(
                    model=self.model,
                    max_tokens=self.max_tokens if self.max_tokens else 1024,
                    temperature=self.temperature if self.temperature is not None else 0.4,
                    system="You are a helpful assistant and Ansible expert.",
                    messages=[{"role": "user", "content": prompt}]
                )
                return to_text(message.content[0].text.strip())

        except Exception as e:
            return to_text(f"Error with {self.provider}: {str(e)}")

        return to_text("Unsupported provider")

class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 1.1
    CALLBACK_TYPE = 'aggregate'
    CALLBACK_NAME = 'llm_analyzer'
    CALLBACK_NEEDS_WHITELIST = True

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.ai_provider = None
        self.analysis_dir = Path("llm_analysis")
        self.analysis_dir.mkdir(exist_ok=True)
        self.task_count = 0
        self.play_count = 0

    def set_options(self, task_keys=None, var_options=None, direct=None):
        super(CallbackModule, self).set_options(task_keys=task_keys,
                                              var_options=var_options,
                                              direct=direct)

        provider = self.get_option('provider')
        api_key = self.get_option('api_key')
        
        # If no specific API key provided, try to get from environment based on provider
        if not api_key:
            api_key = os.getenv(f"{provider.upper()}_API_KEY")

        self.ai_provider = AIProvider(
            provider=provider,
            api_key=api_key,
            model=self.get_option('model'),
            temperature=float(self.get_option('temperature')),
            max_tokens=self.get_option('max_tokens')
        )

    def _save_to_markdown(self, content: str, analysis_type: str, name: str = None):
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        count = self.task_count if analysis_type == "task" else self.play_count
        filename = f"{timestamp}_{analysis_type}_{count}"
        if name:
            # Replace spaces and special characters with underscores
            safe_name = "".join(c if c.isalnum() else "_" for c in name)
            filename = f"{filename}_{safe_name}"
        filename = f"{filename}.md"
        
        filepath = self.analysis_dir / filename
        with open(filepath, 'w') as f:
            f.write(f"# {analysis_type.title()} Analysis\n\n")
            if name:
                f.write(f"**Name:** {name}\n\n")
            f.write(f"**Timestamp:** {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write("## Analysis\n\n")
            f.write(content)

    def v2_playbook_on_task_start(self, task, is_conditional):
        self.task_count += 1
        task_text = yaml.dump([json.loads(json.dumps(task._ds))])
        explanation = self.ai_provider.get_description(task_text=task_text)
        
        # Print to console
        print(f"Explanation: \n{explanation}")
        
        # Save to markdown file
        self._save_to_markdown(explanation, "task", task.get_name())

    def v2_playbook_on_play_start(self, play):
        self.play_count += 1
        play_text = yaml.dump(json.loads(json.dumps(play.get_ds())))
        explanation = self.ai_provider.get_description(play_text=play_text)
        
        # Print to console
        print(f"Explanation: \n{explanation}")
        
        # Save to markdown file
        self._save_to_markdown(explanation, "play", play.get_name())

#!/usr/bin/env python

"""
Setup script for pipe-carrier-portal
"""

import codecs
import os

import setuptools
from setuptools import find_packages
from setuptools import setup

import subprocess
from distutils.command.build import build as _build


package = __import__('pipe_carrier_portal')


DEPENDENCIES = [
    "pytest",
    "nose",
    "ujson",
    "pytz",
    "udatetime",
    "newlinejson",
    "jinja2-cli",
    "statistics",
    "elasticsearch==7.8.1",
]

with codecs.open('README.md', encoding='utf-8') as f:
    readme = f.read().strip()

with codecs.open('requirements.txt', encoding='utf-8') as f:
    DEPENDENCY_LINKS=[line for line in f]

setup(
    author=package.__author__,
    author_email=package.__email__,
    description=package.__doc__.strip(),
    include_package_data=True,
    install_requires=DEPENDENCIES,
    license="Apache 2.0",
    long_description=readme,
    name='pipe-carrier-portal',
    packages=find_packages(exclude=['test*.*', 'tests']),
    url=package.__source__,
    version=package.__version__,
    zip_safe=True,
    dependency_links=DEPENDENCY_LINKS
)


#!/bin/bash

sed "s/’/\\'/" | tr -cd "a-zA-Z0-9 .,\'\n\\\\{}[]()<>=-"

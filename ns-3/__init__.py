import os

__BASE_PATH = os.path.dirname(os.path.abspath(__file__))

def __extend_environ(key, *args):
	old_value = os.environ.get(key, '')
	if old_value != '':
		old_value += os.pathsep
	os.environ[key] = old_value + os.path.join(*args)

__extend_environ('PATH', __BASE_PATH, '_', 'bin')

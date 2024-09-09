import invoke

@invoke.task
def hello(c, name):
    '''Say hello!'''
    invoke.run(f'echo "hello {name}!"')

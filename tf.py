#!/usr/bin/env python
import sys
import importlib
import subprocess

import click

from pathlib import Path


PROJECT_DIR = Path(__file__).parent

PROJECTS = [
    child.name
    for child in PROJECT_DIR.iterdir()
    if child.is_dir() and any(child.glob('*.tf*'))
]

COMMANDS = [
    'plan',
    'apply',
    'destroy',
    'init',
]

def load_arguments(project):
    """
    Load and retrieve arguments for a specific environment within a project.

    This function dynamically loads argument configurations from a module named '{project}.arguments'

    Parameters:
    ----------
    project : str
        The name of the project for which arguments are to be loaded.

    Returns:
    -------
    args : object
        A Python object containing the loaded arguments

    Raises:
    -------
    ModuleNotFoundError:
        If the module '{project}.arguments' is not found, indicating that the argument configurations
        couldn't be loaded.

    Notes:
    -------
    - This function is designed to load and retrieve configuration parameters or arguments for a given
      project. 
    - It expects that a module named '{project}.arguments' exists, and this module should define a function
      named 'load_arguments' that returns the specific arguments

    Example:
    -------
    To load arguments for a project named 'my_project', you can use this
    function as follows:

    >>> args = load_arguments('my_project')

    If the '{project}.arguments' module exists and contains a 'load_arguments' function, the 'args'
    variable will contain the configuration parameters/

    """
    args = ""
    try:
        args_module = importlib.import_module(f'{project}.arguments')
        print(f"Loading arguments for project {project}")
        args = args_module.load_arguments()
    except ModuleNotFoundError:
        print(f'Could not load {project}/arguments module, if you want to load dynamic variables,'
              'including secrets from credstash, create this file.')
    return args


@click.command()
@click.argument('project', type=click.Choice(PROJECTS))
@click.argument('cmd', default='plan', type=click.Choice(COMMANDS))

def terraform(project, cmd):
    commands = [f'cd {project}']

    if cmd == "init":
        commands.append("terraform init")
    elif cmd in ("plan","apply","destroy"):
        args = load_arguments(project)
        command = f'terraform {cmd} {args}'
        commands.append(command)
    else:
        print("Command not supported")

    exit_code = run_commands(";".join(commands))
    sys.exit(exit_code)

def run_commands(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    while True:
        output = process.stdout.readline().decode('utf-8')
        if output == '' and process.poll() is not None:
            break
        if output:
            print(output.strip())
    exit_code = process.poll()
    return exit_code

if __name__ == '__main__':
    terraform()
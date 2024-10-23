from invoke import task
import invoke

def compile_python_module(cpp_name, extension_name):
    invoke.run(
        "g++ -O3 -Wall -Werror -shared -std=c++11 -fPIC "
        "`python3 -m pybind11 --includes` "
        "-I /usr/include/python3.7 -I .  "
        "{0} "
        "-o {1}`python3-config --extension-suffix` "
        "-L. -lcppmult -Wl,-rpath,.".format(cpp_name, extension_name)
    )

@task
def build_cython(c):
    """ Build the cython extension module """
    print("Building Cython Module")
    # Run cython on the pyx file to create a .cpp file
    invoke.run("cython --cplus -3 livox.pyx -o livox.cpp")

    # Compile and link the cython wrapper library
    compile_python_module("livox.cpp", "livox")
    print("* Complete")
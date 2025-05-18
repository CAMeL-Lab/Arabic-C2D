# How to use: python display_tree.py atb3v31.sample
# the output is printed on the terminal
import sys

if __name__ == "__main__":
    try:
        file_name = sys.argv[1]  # Get GOLD file name from user input
    except IndexError:
        print ('Missing argument')
        raise SystemExit

    try:
        inputfile = open(file_name, 'r')
    except IOError:
        print ('File(s) not found')
        raise SystemExit

    tree = inputfile.readline()

    while tree:
        spaces = 0
        stack = []
        for index in range(len(tree)):
            sys.stdout.write(tree[index])
            if tree[index] =='(': stack.append(spaces)
            if tree[index] ==')':
                # stack.pop()
                if tree[index+1] !=')':
                    sys.stdout.write('\n'+' '*(stack[-1]-1))
                    spaces = stack[-1]-2
                    stack.pop()
                else:
                    stack.pop()

            spaces = spaces+1

        tree = inputfile.readline()
        print '\n'

    inputfile.close()
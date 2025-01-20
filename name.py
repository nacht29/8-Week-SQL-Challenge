while True:
    try:
        usr = input("N: ")
        print(usr.lower().replace(" ","-"))
    except KeyboardInterrupt:
        print()
        break

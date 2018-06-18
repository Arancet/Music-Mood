import urllib.request
import time
from bs4 import BeautifulSoup

def main():
    candidate_proxies = ['localhost:8118']
    for proxy in candidate_proxies:

        print ("Trying HTTP proxy %s" % proxy)
        try:
            #create the object, assign it to a variable
            proxy = urllib.request.ProxyHandler({'http': proxy})
            # construct a new opener using your proxy settings
            opener = urllib.request.build_opener(proxy)
            # install the openen on the module-level
            urllib.request.install_opener(opener)
            print("proxy opener installed")
            result = urllib.request.urlopen("http://icanhazip.com")
            #result = urllib.request.urlopen("http://www.google.com")
            soup = BeautifulSoup(result, 'html.parser')
            print ("Got URL using proxy " + str(proxy))
            print(str(soup))
            #break
        except Exception as e:
            print ("Trying next proxy in 5 seconds: " + str(e))
            time.sleep(5)

if __name__ == '__main__':
    main()
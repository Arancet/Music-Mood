import urllib.request
import time
from bs4 import BeautifulSoup

def main():
    candidate_proxies = ['localhost:8118']
    for proxy in candidate_proxies:

        print ("Trying HTTP proxy %s" % proxy)
        try:
            while True:
                #create the object, assign it to a variable
                proxy_req = urllib.request.ProxyHandler({'http': proxy})
                # construct a new opener using your proxy settings
                opener = urllib.request.build_opener(proxy_req)
                # install the openen on the module-level
                urllib.request.install_opener(opener)
                result = urllib.request.urlopen("http://icanhazip.com")
                #result = urllib.request.urlopen("http://www.google.com")
                soup = BeautifulSoup(result, 'html.parser')
                print("External IP:  " + str(soup))
                #break
                time.sleep(60)
        except Exception as e:
            print ("Trying next proxy in 5 seconds: " + str(e))
            time.sleep(5)

if __name__ == '__main__':
    main()
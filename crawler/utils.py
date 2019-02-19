import requests
from bs4 import BeautifulSoup
import re
from peewee import *
import time



def add_link_to_db(link):
    try:
        Url.create(link=link, is_crawled=False)
    except IntegrityError:
        return
    

def get_url_from_db():
    url = Url.select().order_by(fn.Random()).limit(1).get()
    return url


def count_all_urls():
    return Url.select().count()
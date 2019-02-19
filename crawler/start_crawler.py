import requests
from bs4 import BeautifulSoup
import re
from peewee import *
import time
import sys


db_dir = db = "dbs/" + sys.argv[1].split("//")[1] + ".db"
db = SqliteDatabase(db_dir)


def add_link_to_db(link):
	try:
		Url.create(link=link)
	except IntegrityError:
		return


def get_url_from_db():
	url = Url.select().order_by(fn.Random()).limit(1).get()
	return url


def count_all_urls():
	return Url.select().count()


def count_all_crawled_urls():
	return Url.select().where(Url.crawled_num > 0).count()



class BaseModel(Model):
	class Meta:
		database = db


class Url(BaseModel):
	link = CharField(unique=True)
	crawl_num = IntegerField(default=0)
	# is_crawled = BooleanField(default=False)


def init_db(root):
	db.connect()
	db.create_tables([Url])
	add_link_to_db(root)


def run(root, num):
	init_db(root)

	crawled_links_num = 0
	while crawled_links_num < num:
		new_url = get_url_from_db()

		if new_url.crawl_num > 0:
			requests.get(new_url.link)
			new_url.crawl_num += 1
			new_url.save()
		else:
			new_url.crawl_num += 1
			new_url.save()

			content = requests.get(new_url.link).text
			soup = BeautifulSoup(content, "lxml")

			for link in soup.find_all('a'):
				if link == None:
					continue

				link = link.get('href')
				if link and re.search(r"^/[a-zA-Z]", link):
					link = new_url.link + link
					add_link_to_db(link)

				elif link and link.startswith(root):
					add_link_to_db(link)

		crawled_links_num += 1

		if crawled_links_num % 10 == 0:
			print("crawled links:", crawled_links_num)
		time.sleep(5)


if __name__ == "__main__":
	root_url = sys.argv[1]
	required_links_num = int(sys.argv[2])

	run(root_url, required_links_num)


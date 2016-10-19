# Overview
I have spend time to make sure solution is simple yet extensible and scalable in the long term. UI is very minimal, just enough to start the parsing process. 
This solution demonstrates an approach to crawling a web site. Due to time constraints a lot of corners where cut and as a result the code is not production quality. The aim is demonstrate an approach rather than produce perfect code.
 
# Performance
Currently due to the restriction of free tiers I run a very small (20 MB) redis instance (with max 20 connections) and 1 small worker instance on heroku + 1 web instance. I also only run 10 parallel jobs, however it can be scaled to thousands if necessary, which would speed up parsing dramatically.

# Solution approach
While solving the problem I have aimed to build a crawler which has capability to parse non trivial sites for example wikipedia.org. Also being able to do some site analysis was also a priority.

## Approach in a nutshell
1. Pass parent url and url to parse
2. Save node to the database
3. Create a relationship with parent
4. Discover and classify all resources, if the node wasn't parsed before
5. For each resource queue up a new job to process

Essentially what you get is a recursive function, which rather than calling itself creates a new job in the queue. A termination of the recursion is either discovering a resource which doesn't contain links (e.g. image or css) or processing url which has been already processed. 
The total number of jobs queued will be equal to number of relationships. The speed at which resources are parsed is then controlled by number of parallel jobs, for the demo purposes it is set to 10 parallel jobs, which isn't fast at all. I have left at fairly low to prevent from triggering Cloudflare ddos protection.

## Tech Stack

### Ruby
Ruby has good stable frameworks, while it's not most performant language by itself the libraries for parsing are written in C (nokogiri), so the speed of the languages itself should have a significant impact on performance.
  
### Sinatra
As the interface of the site is very simple, I have decided to use Sinatra rather than heavy weight Rails.

### Redis
I use Redis as my in memory database to store queues of jobs which need to be processed. Redis is very fast and while there is very limited number of data stored it can be scaled to tackle bigger sites. Redis is heavily used by Sidekiq (background job processing framework) and also provides Sidekiq reliability by storing state of each job in case job fails or dyno restarts.

### Neo4j
I decided to use graph database as the structure of the site fits much better into the graph rather than a table. I represent each resource (html page, css, image) as a node and a link to that resource a neo4j relationship. Another reasons for using Neo4j is scalability and finally ability to build complex queries to understand relations. For example:
To find out how many pages are 5 clicks away from home page is very easy to do in graph database compared to SQL database. I also use neo4j web interface to visualise the structure of the site. 
 
### Sidekiq
I use sidekiq as a backbone for the processing, it gives things like retry logic, parallelism, queue management as well as inbuilt interface to see state of all queues.

# Running locally

## Prerequisites
 - Ruby 2.3.0 or higher
 - Redis
 - Neo4j server
 
## Running
 1. clone code
 2. navigate to the root of the project
 3. Run `bundle install` to install dependencies
 4. Run `redis-server` to start redis
 5. Run `sidekiq -r ./workers/page_downloader_worker.rb` to start sidekiq process 
 6. Start server by running `bundle exec rackup config.ru`
 7. Navigate to `http://localhost:9292` in your browser

# Testing
I have done a big part of the development using test first approach. Also for integration tests I spin off a local server with a know site structure and test against it.

## Running tests

## Prerequisites
- Ruby 2.3.0 or higher
- Neo4j server

There is no need to use sidekiq and redis in testing as I mock those libraries.
IMPORTANT! For integration tests whole Graph DB will be cleared

## Running
1. clone code
2. run `bundle install`
3. run `rspec` to execute tests

# UI
I haven't spent much time creating UI, I am using `https://web-spider.herokuapp.com/sidekiq/` to monitor the status of web spider. Once spider is completed you can check the site structure via `https://web-spider.herokuapp.com/sitemap?url=http://simplesamplesite.com`. It's very basic only shows the child and parent nodes.
To get a better understanding of the data I use neo4j web interface and it's query language (cypher). It gives you a flexible way to create reports such as give me images which are linked by 10 or more pages, show pages which are further than 5 clicks from home page, etc. Some of this functionality could be exposed to the end user.

## Approach

## Deploying
I use Heroku to deploy the app, it starts one web server and one worker with max 10 workers.

# Issues IMPORTANT!
In the current version of neo4j driver there is an intermittent bug which might result in jobs and sinatra failing to connect to DB, there is currently no fix for it and I am looking into using previous version of the driver to overcome this problem. Unfortunately this makes app unstable and it might fail site parsing. 

# Things need improving
- Simplifying process of running locally
- Parse more types of files .e.g pdfs
- Allow to change number of worker dynamically
- Support to tweak how aggressive crawlers are (to prevent DDoS certain servers)
- Support for robots.txt
- Better visualisation of the site tree
- Testing
- Security
- Client/Server side validation

[neo4j web interface]: https://www.dropbox.com/s/n4sesbkzci43b97/Screenshot%202016-10-19%2019.53.31.png?raw=1
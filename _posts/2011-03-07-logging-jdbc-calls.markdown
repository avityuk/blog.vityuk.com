---
layout: post
title: Logging JDBC calls
tags: [java, logging, jdbc]
date: 2011-03-07 16:55:00 +0200
---
Today I found some my drafts of JDBC logger library. And finally decided to upload it on [Google code][1]. The main idea of the library is to transparently intercept JDBC calls and log queries (even for PreparedStatement).

<a name="more" />

It's always painful to analyze log with JDBC calls:

	1025 [main] INFO JDBC - insert into TEST (NAME, POS) VALUES(?, ?)

Looks not very useful unless you are printing parameters passed to `PreparedStatement`. Even some of my colleagues pointed that they hate `PreparedStatement` because of it.

Pretty straightforward solution is to intercept JDBC calls and create some simple log statement. That\'s what actually library is doing. I won\'t describe it\'s usage here, since I already did it on [usage page][2]. In short the only thing you have to do is to wrap data source: `new LoggableDataSource(ds, new Slf4JLogger())`. And that\'s what you automatically get:

	394 [main] INFO JDBC - insert into TEST (NAME, POS) VALUES(name-0, 0)

It works with any `DataSource` and various logging libraries. It could be useful during development and testing.

[1]: http://code.google.com/p/jdbc-logger/
[2]: http://code.google.com/p/jdbc-logger/wiki/Usage

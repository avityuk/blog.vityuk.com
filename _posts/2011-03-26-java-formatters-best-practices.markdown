---
layout: post
title: Java Formatters Best Practices
tags: [java, formatting, multithreading]
date: 2011-03-26 17:54:00 +0200
---
Java API has set of classes for formatting and parsing dates and
numbers. Mostly used are: `java.text.DateFormat` and `java.text.NumberFormat`. Often when interviewing candidates I ask them whether JDK date and number formatters are thread-safe. Surprisingly most of them don't know the right answer, hence I decided to describe common pitfalls with formatters usage.

<!-- more -->

As you can guess both `DateFormat` and `NumberFormat` are not thread-safe. This is old known Java API design mistake. Nowadays all agreed that they supposed to be immutable instead of mutable. There is awesome alternative for dates - [Joda Time][1]. Which is pretty mature and was taken as a base for [JSR-310][2]. I am personally recommend to stick with Joda Time if you can choose, because on our project we have great impression of using it. But if you have to deal with JDK date (and I don't know good alternatives for numbers) you should be ready to use them correctly. Let's go over formatting common patterns. In my examples I will use `SimpleDateFormatter` for formatting date. But all examples applicable for `NumberFormat` and for parsing strings.

### 1. Local format	{#1}
{% highlight java %}
import java.text.SimpleDateFormat;
import java.util.Date;

public class FormatLocal {
  public static void main(String[] args) {
    format(new Date());
  }

  static String format(Date date) {
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    return format.format(date);
  }
}
{% endhighlight %}

This is the most obvious and straightforward way of formatter usage. You just create local instance and use it right away. In most cases it's sufficient and preferable way to use it. But a lot of people trying to optimize it and turn it into [2](#2).

### 2. Shared not synchronized format	{#2}
{% highlight java %}
import java.text.SimpleDateFormat;
import java.util.Date;

public class FormatSharedBuggy {
  public static void main(String[] args) {
    format(new Date());
  }

  // DON'T DO IT!!! DateFormat is not thread-safe
  private static final SimpleDateFormat FORMAT =
	new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  static String format(Date date) {
    return FORMAT.format(date);
  }
}
{% endhighlight %}

This solution is a result of assumption (which looks logically) that `SimpleDateFormat` is thread-safe. But it's not and this example is buggy. In multithread environment you'll definitely get unpredictable results. **DON'T DO IT!!!**

### 3. Shared synchronized format	{#3}
{% highlight java %}
import java.text.SimpleDateFormat;
import java.util.Date;

public class FormatSharedSynchronized {
  public static void main(String[] args) {
    format(new Date());
  }

  // It's safe to reuse it from synchronized method
  private static final SimpleDateFormat FORMAT =
	new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  synchronized static String format(Date date) {
    return FORMAT.format(date);
  }
}
{% endhighlight %}

This is quick obvious fix of previous approach. You just synchronize access to formatter. But this is not recommended way. This solution is not scalable by nature and suffer from thread contention. On multiprocessor systems it could become a bottleneck. And in this case even the [1](#1) solution is a better way to go.

### 4. Shared thread local format	{#4}
{% highlight java %}
import java.text.SimpleDateFormat;
import java.util.Date;

public class FormatThreadLocal {
  public static void main(String[] args) {
    format(new Date());
  }

  private static final ThreadLocal<SimpleDateFormat> FORMAT = new ThreadLocal<SimpleDateFormat>() {
    @Override
    protected SimpleDateFormat initialValue() {
      return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    }
  };

  static String format(Date date) {
    return FORMAT.get().format(date);
  }
}
{% endhighlight %}

But if you really think (at this place you should measure real performance benefit) you will gain from formatter reuse, you should consider to use [TreadLocal][3]. In this example formatter will be shared only within thread.

We reviewed all cases and I would really recommend to keep away from [2](#2) and [3](#3) solutions. [1](#1) example is straightforward and preferable, unless you undesrstand that you'll win from reusing instance - then you should go with [4](#4). These advices applicable for any not thread-safe classes, so you can use them as patterns. But for your classes prefer immutability, which is naturally thread-safe.

[1]: http://joda-time.sourceforge.net/ 
[2]: http://java.net/projects/jsr-310/ 
[3]: http://download.oracle.com/javase/6/docs/api/java/lang/ThreadLocal.html 

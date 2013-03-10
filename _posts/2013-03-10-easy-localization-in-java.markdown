---
layout: post
title: Localization in Java can be easy
tags: [java, localization, i18n, formatting]
date: 2013-03-10 16:40:00 -0800
---
It's being a while since my last post. Recently I wrote small localization library for Java. It's still in development but I wanted to share main ideas.

JDK localization capabilities are comprehensive enough but not easy to use and it misses very important concept of [Plural Rules][1]. IMHO [GWT][5] is the only Java framework I know which did localication right. I decided to bring these ideas to server side and created [ginger][2]. Here is the list of it's core ideas:

* Ease of use
* Compatibility with JDK localization features
* Type safety
* Plural rules support
* Popular libraries and frameworks support

<!-- more -->

Let's get to some examples.

This is the simplest way to initialize library:
{% highlight java %}
Localization localization = new LocalizationBuilder()
        .withResourceLocation("classpath:demo.properties")
        .build();
{% endhighlight %}
This code creates instance of `Localization` which I will use in further examples. There are additional methods in `LocalizationBuilder` for more flexible configuration: locale resolvers, caching options, resource loaders and additional properties files.

## Constants

demo_en.properties (standard Java properties file except that it supports UTF-8 encoding without additional tranformation):
{% highlight properties %}
day=day
week.start.day=0
# Comma separated list
week.days=Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
{% endhighlight %}

Now type safety comes to the stage. We need to define interface which extends `Localizable` interface and defines methods corresponding to constansts defined in the properties file.
{% highlight java %}
public interface LocalizableConstants extends Localizable {
    String day();
    Integer weekStartDay();
    List<String> weekDays();
}
{% endhighlight %}
Camel case method names are transformed into dot separated property keys. Method can return any primitive wrapper, String, List or Map.

In order to start using localized constants corresponding to the current locale we need to get instance of `LocalizableConstants`. Note, that default `LocaleResolver` implmentation uses `Locale.getDefault()`.
Real application would do that only once and then reuse the instance. `Localizable` instance is thread-safe and independent of current locale.

Getting localized values is really easy:
{% highlight java %}
System.out.println(constants.day());
System.out.println(constants.weekStartDay());
System.out.println(constants.weekDays());
{% endhighlight %}

Output:

	day
	0
	[Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]

## Messages

The main difference between constants and messages is that messages have parameterized values in text. ginger's message is backed by JDK's [MessageFormat][3] with additional enhancements.

demo_en.properties with messages:
{% highlight properties %}
planet.event=At {1,time} on {1,date}, there was {2} on planet {0,number,integer}.
{% endhighlight %}
Property value follows [MessagesFormat][3] syntax:

1. `{0,number,integer}` number formatted as integer. 1st format parameter
2. `{1,time}` time part of a Date. 2nd format parameter
3. `{1,date}` date part of a Date. 2nd format parameter
4. `{2}` default format and depends on parameter type. 3rd format parameter

Similar to constants messages should be defined as methods on `Localizable` interface. With the only difference that methods for messages should have parameters.
{% highlight java %}
public interface LocalizableMessages extends Localizable {
    String planetEvent(int planet, Date eventDate, String event);
}
{% endhighlight %}
Message method supports the same set of parameter types which is supported by [MessageFormat][3]. As an additional benefit it also supports all [Joda Time][4] types.

Instance of `LocalizableMessages` can be created similar to example with constants. Furthermore they are no different to constants and could be defined together.

And this how we can create message with specified parameters:
{% highlight java %}
int planet = 7;
String event = "a disturbance in the Force";
System.out.println(messages.planetEvent(planet, new Date(), event));
{% endhighlight %}

Output:

	At 8:10:33 PM on Mar 9, 2013, there was a disturbance in the Force on planet 7.

As I said, it's easy!

## Plurals

English speaking people would probably say: "What's the matter? 1 - single, 2..n - plural". Ok, but it does not work for all languages. Just look at [list of languages and plural rules][6]. For examples, in Russian there are three forms:

* one - n mod 10 is 1 and n mod 100 is not 11
* few - n mod 10 in 2..4 and n mod 100 not in 12..14
* many -  n mod 10 is 0 or n mod 10 in 5..9 or n mod 100 in 11..14

Looks pretty bad, isn't it? And it's not the worst case. There is [ICU][7] project which has C++ and Java implementation and seems to be the most comprehensive internationalization library. The downside is it's not easy to use and it can be an overkill for small and medium size projects.

This was original reason why I decided to create ginger. Make pluralization simple.

Let's consider the following demo_en.properties. This time with messages for different plural forms:
{% highlight properties %}
users.found[0]=No users found
users.found[one]=Found one user
users.found[other]=Found {0} users
{% endhighlight %}
Parameters in square brackets have plural form selectors. Different languages may have different selectors. `one`, `other` and `many` are the most commonly used selectors. Exact list of selector for any particular language can be found at [unicode.org][6]. `0` and `1` are special selectors and can be used independently of language for exact count match.

Parameters used for plural form selection should be annotated with `@PluralCount` annotation.
{% highlight java %}
public interface LocalizableMessages extends Localizable {  
    String usersFound(@PluralCount int usersCount);
}
{% endhighlight %}

And now it can be used in the actual code.
{% highlight java %}
System.out.println(messages.usersFound(0));
System.out.println(messages.usersFound(1));
System.out.println(messages.usersFound(2));
{% endhighlight %}

Displays messages based on passed plural count:

	No users found
	Found one user
	Found 2 users

## Selectors

Selectors are similar to plurals. You might need to choose message based on something besides a count. For example, you want to display different messages based on person's gender.
{% highlight java %}
public enum Gender {
    FEMALE,
    MALE
}
{% endhighlight %}

And you have messages corresponding to `FEMALE` and `MALE` `Gender`:
{% highlight properties %}
present.sent[FEMALE]=She sent you a present
present.sent[MALE]=He sent you a present
{% endhighlight %}

This how method definition for message with gender selector looks like. 
{% highlight java %}
public interface LocalizableMessages extends Localizable {
	String presentSent(@Select Gender gender);
}
{% endhighlight %}
`@Select` annotation indicates that this parameter is a selector.

The following code prints messages for `MALE` and `FEMALE` `Gender`.
{% highlight java %}
System.out.println(messages.presentSent(Gender.MALE));
System.out.println(messages.presentSent(Gender.FEMALE));
{% endhighlight %}

As expected output displays messages based on `Gender` parameter:

	She sent you a present
	He sent you a present


This was brief overview of [ginger's][2] core features. I also published [above examples on Github][8]. I intentionally didn't cover [Spring][9] and JSP integration in this post and will dedicate separate post for them.

Should you have any questions or feature requests feel free to create [Github issue](https://github.com/avityuk/ginger/issues). I am also planning to add more detailed information on the [project page][2].

You can add it to you project using Maven:
{% highlight xml %}
<dependency>
    <groupId>com.vityuk</groupId>
    <artifactId>ginger-core</artifactId>
    <version>0.2.1</version>
</dependency>
{% endhighlight %}

All Maven artifacts including [Spring][9] and JSP integration are available on [public Maven repositiories](http://search.maven.org/#search%7Cga%7C1%7Cginger)

[1]: http://cldr.unicode.org/index/cldr-spec/plural-rules "Plural Rules on unicode.org"
[2]: https://github.com/avityuk/ginger
[3]: http://docs.oracle.com/javase/6/docs/api/java/text/MessageFormat.html
[4]: http://joda-time.sourceforge.net
[5]: https://developers.google.com/web-toolkit/
[6]: http://www.unicode.org/cldr/charts/supplemental/language_plural_rules.html
[7]: http://site.icu-project.org
[8]: https://github.com/avityuk/ginger-demo/tree/master/simple
[9]: http://www.springsource.org/spring-framework
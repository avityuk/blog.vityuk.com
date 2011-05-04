---
layout: post
title: Lost Stack Trace
date: 2011-03-31 21:41:00 +0300
---
Last week our team faced another *NullPointerException* in our
development environment. As usual I started investigate log files to get
full stack trace and find out reason of exception. Surprisingly, but the
message I saw in log file was like:    ERROR: MyClass -
java.lang.NullPointerException

I realized that there was something wrong in logging code, hence we are
loosing stack trace. I checked code which produces this log and didn\'t
find anything unusual. Then I asked my colleague to double check it may
be I miss something. He reproduced the same exception on his desktop and
showed me nice log statement with full stack trace. We started to feel
that there is some magic behind that. Whole team started googling and
finally we found the answer.

<a name="more" />There was [discussion on stackoverflow][1] about this issue. And answer
was there. As we guessed it was HotSpot magic. Here is example which
reveals the problem:    public class LostStackTrace {  public static
void main(String[] args) {    m();  }  private static void m() {    for
(int i = 0; i < 100000; i++) {      try {        ((Object)
null).hashCode();      } catch (NullPointerException e) {        if
(e.getStackTrace().length == 0) {          System.out.println(i);       
e.printStackTrace();          return;        }      }    }  }}

If you run it with *java -server* you\'ll see something like this:   
18658java.lang.NullPointerException

Here it is, on 18658 iteration (funny thing about that is that I tested
it on few PCs and it always happens on 18658 or 20706 iteration) JVM
recompiles bytecode with optimization for exception: use preallocated
exception without stack trace instead of creating it each time. I
suppose Sun did it for optimizing stupid things like [using exceptions
for flow control][2].

Good thing that Sun allowed us to disable this behavior:> The compiler
in the server VM now provides correct stack backtraces
> for all \"cold\" built-in exceptions. For performance purposes, when
> such an exception is thrown a few times, the method may be recompiled.
> After recompilation, the compiler may choose a faster tactic using
> preallocated exceptions that do not provide a stack trace. To disable
> completely the use of preallocated exceptions, use this new flag:  
> **-XX:-OmitStackTraceInFastThrow**.
{: cite="http://java.sun.com/j2se/1.5.0/relnotes.html"}

Finally we added this parameter to start scripts on all our development
environments. You can try it with above sample code: *java -server
-XX:-OmitStackTraceInFastThrow*.

<div class="blogger-post-footer">
![](https://blogger.googleusercontent.com/tracker/8677550483635565983-4657344291289083740?l=blog.vityuk.com){:
width="1" height="1"}
</div>



[1]: http://stackoverflow.com/questions/2411487/nullpointerexception-in-java-with-no-stacktrace 
[2]: http://www.google.com/search?q=using+exceptions+for+flow+control 

---
layout: post
title: How Scala compiler stores meta information
date: 2010-12-05 12:59:00 +0200
---
<div class="separator" style="clear: both; text-align: center;">
![](http://3.bp.blogspot.com/_MzPDIAgS1ow/TPtvknz8OgI/AAAAAAAARLI/mShNq4h6jxc/s320/scala.jpg){:
border="0" height="253" width="320"}
</div>

I was always wondering how Scala compiler fits into Java class file with
all it\'s comprehensive language constructions. I felt there was some
magic... Later in Scala 2.8 I faced a problem with calling method with
default parameters using reflection. From a quick glance it seemed that
there nothing complex. But wait, Scala allows methods overloading and
how do you know which method has default parameters?

<a name="more" />Here we go. There is a *Pickled Scala Signature*. Thought this is
required information for tools, libraries and IDEs developers I found
only one [document][1] dedicated to this topic. Which is most likely
Scala 2.7 -&gt; 2.8 migration manual. Prior to Scala 2.8 comiler stored
signature bytes in class file attributes called *ScalaSig*. [According
to JVM spec][2] custom attributes are allowed since JVM simply ignores
unknown attributes. With this approach implement Scala reflection was
painful. You had to parse class file again (why? JVM already did it) and
only then parse signature itself. As of Scala 2.8 the things get
changed. *ScalaSig* attribute has been replaced by runtime
*scala.reflect.ScalaSignature* annotation. The task became much more
easier. Annotation has only single String attribute called *bytes* which
contains encoded (pickled) signature (above there is reference to Scala
SID which describes bytes encoding in details).

I spent some time on Scala compiler sources investigation. And created
small tool which helps understanding of Scala signature. It visualizes
pickle signature. You can check it out here:
[https://github.com/avityuk/scala-pickled-visualizer][3]. Manual and
some information on pickle format provided in README. Here I just want
to show few sample output diagrams.

\#### Default parameters:

    class TestClass1 {  def met(param1: Long) = "method-1"  def
met(param1: Long = 445, param2: String) = "method-2"}

  
Diagram (default parameter vertex is highlighted):<div class="separator"
style="clear: both; text-align: left;">
[![](http://2.bp.blogspot.com/_MzPDIAgS1ow/TPtpr0W5ldI/AAAAAAAARLA/zOemmMcQpQg/s320/TestClass1.jpg){:
border="0" height="155" width="320"}][4]{: imageanchor="1"
style="margin-left: 1em; margin-right: 1em;"}
</div>

\#### Annotations:

    @XmlTypeclass TestClass2 {  @XmlAttribute  val f1 = 150.75}

  
Diagram:<div class="separator" style="clear: both; text-align: left;">
[![](http://3.bp.blogspot.com/_MzPDIAgS1ow/TPtuhFeIZ7I/AAAAAAAARLE/dDnzoO_viLM/s320/TestClass2.jpg){:
border="0" height="194" width="320"}][5]{: imageanchor="1"
style="margin-left: 1em; margin-right: 1em;"}
</div>

<div class="blogger-post-footer">
![](https://blogger.googleusercontent.com/tracker/8677550483635565983-7435117754692384748?l=blog.vityuk.com){:
width="1" height="1"}
</div>



[1]: http://www.scala-lang.org/sid/10 
[2]: http://java.sun.com/docs/books/jvms/second_edition/html/ClassFile.doc.html#16733 
[3]: https://github.com/avityuk/scala-pickled-visualizer 
[4]: http://2.bp.blogspot.com/_MzPDIAgS1ow/TPtpr0W5ldI/AAAAAAAARLA/zOemmMcQpQg/s1600/TestClass1.jpg 
[5]: http://3.bp.blogspot.com/_MzPDIAgS1ow/TPtuhFeIZ7I/AAAAAAAARLE/dDnzoO_viLM/s1600/TestClass2.jpg 

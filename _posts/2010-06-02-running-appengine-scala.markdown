---
layout: post
title: Getting started with AppEngine + Scala
poster: {url: 'http://2.bp.blogspot.com/_MzPDIAgS1ow/TAaZmre_WXI/AAAAAAAAOFc/a2_E3nAacQI/s320/scala_appengine.png', width: '315px', height: '186px'}
date: 2010-06-02 21:41:00 +0300
---
This time, after long time-out I decided to continue blogging in english. Sorry for my english in advance, but I will try to do my best ;-)I spent some time playing with [Google App Engine][2] and [Scala][3] integration so I think it could be helpful for somebody else. Since they are both innovative technologies I could not resist the temptation to use unusual build tool with self-explanatory name [simple-build-tool][4]. In short, this is Maven-like build tool which actually works with Maven repositories (using Apache Ivy). But instead of boilerplate xml you get Scala code.  
<a name="more" />  
First of all you need to [install simple-build-tool][5].  
Let\'s create our project dir:

	$ mkdir gae_scala

And run simple-build-tool:  

	$ cd gae_scala
	$ sbt

~~~~~
Project does not exist, create new project? (y/N/s) y
Name: gae_scala
Organization: com.example
Version [1.0]: 
Scala version [2.7.7]: 
sbt version [0.7.3]: 
Getting Scala 2.7.7 ...
:: retrieving :: org.scala-tools.sbt#boot-scala
 confs: [default]
 2 artifacts copied, 0 already retrieved (9911kB/94ms)
Getting org.scala-tools.sbt sbt_2.7.7 0.7.3 ...
:: retrieving :: org.scala-tools.sbt#boot-app
 confs: [default]
 15 artifacts copied, 0 already retrieved (4023kB/153ms)
[success] Successfully initialized directory structure.
[info] Building project gae_scala 1.0 against Scala 2.7.7
[info]    using sbt.DefaultProject with sbt 0.7.3 and Scala 2.7.7
> 
~~~~~

Now we have initial project skeleton. You can run *help* command and read about existsing commands.  
There is existing [google app engine plugin for sbt][6]. Let\'s build and install it. Run in some temporary directory:
 
	$ git clone git://github.com/Yasushi/sbt-appengine-plugin.git
	$ cd sbt-appengine-plugin
	$ sbt
	$ publish-local

~~~~~
..........................................................................
[info] == publish-local ==
[info] :: publishing :: net.stbbs.yasushi#sbt-appengine-plugin
[info]  published sbt-appengine-plugin to /home/brick/.ivy2/local/net.stbbs.yasushi/sbt-appengine-plugin/2.1-SNAPSHOT/jars/sbt-appengine-plugin.jar
[info]  published sbt-appengine-plugin to /home/brick/.ivy2/local/net.stbbs.yasushi/sbt-appengine-plugin/2.1-SNAPSHOT/poms/sbt-appengine-plugin.pom
[info]  published ivy to /home/brick/.ivy2/local/net.stbbs.yasushi/sbt-appengine-plugin/2.1-SNAPSHOT/ivys/ivy.xml
[info] == publish-local ==
[success] Successful.
[info] 
[info] Total time: 9 s, completed 02.06.2010 21:38:55
~~~~~

  
We installed gae plugin for sbt, getting back to *gae\_scala*\:

	$ mkdir project/build
	$ mkdir project/plugins

Create *project/plugins/plugins.scala* with your favourite editor:
{% highlight scala %}
import sbt._

class Plugins(info: ProjectInfo) extends PluginDefinition(info) {
  val appEngine = "net.stbbs.yasushi" % "sbt-appengine-plugin" % "2.1-SNAPSHOT"
}
{% endhighlight %}

Above we [defined dependency][7] on App Engine plugin (the same as maven plugin dependency).  
Create *project/build/project.scala* custom [build configuration][8] with appengine support:
{% highlight scala %}
import sbt._

class AppengineScalaProject(info: ProjectInfo)
   extends AppengineProject(info) with DataNucleus
{% endhighlight %}

*DataNucleus* trait adds [domain classes enhacer][9] to the build process. It is required only when used with JDO or JPA.  
At the moment we have sbt project with configured appengine plugin. Specify App Engine SDK home:

	$ export APPENGINE_SDK_HOME=~/installed/appengine-java-sdk

Run *sbt* shell and *update* command:

~~~~~
[info] Recompiling project definition...
[info]    Source analysis: 1 new/modified, 0 indirectly invalidated, 0 removed.
[info] Building project gae_scala 1.0 against Scala 2.7.7
[info]    using AppengineTestProject with sbt 0.7.3 and Scala 2.7.7
> update
[info] 
[info] == update ==
[info] :: retrieving :: com.example#gae_scala_2.7.7 [sync]
[info]  confs: [compile, runtime, test, provided, system, optional, sources, javadoc]
[info]  1 artifacts copied, 0 already retrieved (102kB/37ms)
[info] == update ==
[success] Successful.
[info] 
[info] Total time: 1 s, completed 02.06.2010 22:17:07
> 
~~~~~

Now we need to create *web.xml* and *appengine-web.xml* descriptors for out application:

	$ mkdir -p src/main/webapp/WEB-INF

Create *src/main/webapp/WEB-INF/web.xml* file:
{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns="http://java.sun.com/xml/ns/javaee"
xmlns:web="http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" version="2.5">
        <servlet>
                <servlet-name>HelloWorld</servlet-name>
                <servlet-class>com.example.HelloWorld</servlet-class>
        </servlet>
        <servlet-mapping>
                <servlet-name>HelloWorld</servlet-name>
                <url-pattern>/hello</url-pattern>
        </servlet-mapping>
        <welcome-file-list>
                <welcome-file>index.html</welcome-file>
        </welcome-file-list>
</web-app>
{% endhighlight %}

Create *src/main/webapp/WEB-INF/appengine-web.xml* file:
{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<appengine-web-app xmlns="http://appengine.google.com/ns/1.0">
        <application>gae_scala</application>
        <version>1</version>
</appengine-web-app>
{% endhighlight %}  

At last, we need to create our `HelloWorld` servlet:

	$ mkdir -p src/main/scala/com/example

*src/main/scala/com/example/HelloWorld.scala*:
{% highlight scala %}
package com.example

import javax.servlet.http._

class HelloWorld extends HttpServlet {
  override def doGet(req: HttpServletRequest, resp: HttpServletResponse) = {
    resp.setContentType("text/plain")
    resp.getWriter().println("Hello World!")
  }
}
{% endhighlight %}

Now we are ready to run:

~~~~~
$ sbt
> dev-appserver-start
[info] 
[info] == compile ==
[info]   Source analysis: 1 new/modified, 0 indirectly invalidated, 0 removed.
[info] Compiling main sources...
[info] Compilation successful.
[info]   Post-analysis: 1 classes.
[info] == compile ==
[info] 
[info] == copy-resources ==
[info] == copy-resources ==
[info] 
[info] == prepare-webapp ==
[info] == prepare-webapp ==
[info] 
[info] == dev-appserver-start ==
[info] == dev-appserver-start ==
[success] Successful.
[info] 
[info] Total time: 1 s, completed 02.06.2010 22:44:55
..........................................................................
~~~~~

Open <http://localhost:8080/hello> in web browser and enjoy result...  
Here are several useful actions:

* *dev-appserver-start* - starts development server
* *dev-appserver-stop* - stops development server
* *enhance* - executes ORM enhancement
* *update-webapp* - uploads application to Google App Engine server
* *action* - prints all available actions

Now you are ready to code something. Have a fun!

[1]: http://2.bp.blogspot.com/_MzPDIAgS1ow/TAaZmre_WXI/AAAAAAAAOFc/a2_E3nAacQI/s1600/scala_appengine.png 
[2]: http://code.google.com/appengine/ 
[3]: http://www.scala-lang.org/ 
[4]: http://code.google.com/p/simple-build-tool/ 
[5]: http://code.google.com/p/simple-build-tool/wiki/Setup 
[6]: http://github.com/Yasushi/sbt-appengine-plugin 
[7]: http://code.google.com/p/simple-build-tool/wiki/SbtPlugins 
[8]: http://codjavascript:void(0)e.google.com/p/simple-build-tool/wiki/BuildConfiguration 
[9]: http://code.google.com/intl/en/appengine/docs/java/datastore/usingjdo.html#Enhancing_Data_Classes 

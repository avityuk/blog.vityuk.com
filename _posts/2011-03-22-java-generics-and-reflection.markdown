---
layout: post
title: Java Generics and Reflection
tags: [reflection, java, generics]
date: 2011-03-22 09:46:00 +0200
---
\"Officially\" Java does not have information about generic types in runtime. But it\'s not absolutely true. There are some cases, which are utilized by smart frameworks like Spring and Google Guice. Let\'s explore these cases!

<!-- more -->

As usual for reflection, there is special interface: `java.lang.reflect.Type`. There are several successor interfaces:

* `java.lang.Class` - represents usual class
* `java.lang.reflect.ParameterizedType` - class with generic parameter (List<String>)
* `java.lang.reflect.TypeVariable` - generic type literal (List<T>, T - type variable)
* `java.lang.reflect.WildcardType` - wildcard type (List<? extends Number>, \"? extends Number\" - wildcard type)
* `java.lang.reflect.GenericArrayType` - type for generic array (T\[\], T - array type)

Below is utility class demostrating processing of `java.lang.reflect.Type`. I will use it in further examples for getting string representation of declared types.
{% highlight java %}
import java.lang.reflect.GenericArrayType;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.TypeVariable;
import java.lang.reflect.WildcardType;
import java.util.HashSet;
import java.util.Set;

public class Generics {
  public static String typeToString(Type type) {
    StringBuilder sb = new StringBuilder();
    typeToString(sb, type, new HashSet<Type>());
    return sb.toString();
  }

  private static void typeToString(StringBuilder sb, Type type, Set<Type> visited) {
    if (type instanceof ParameterizedType) {
      ParameterizedType parameterizedType = (ParameterizedType) type;
      final Class<?> rawType = (Class<?>) parameterizedType.getRawType();
      sb.append(rawType.getName());
      boolean first = true;
      for (Type typeArg : parameterizedType.getActualTypeArguments()) {
        if (first) {
          first = false;
        } else {
          sb.append(", ");
        }
        sb.append('<');
        typeToString(sb, typeArg, visited);
        sb.append('>');
      }
    } else if (type instanceof WildcardType) {
      WildcardType wildcardType = (WildcardType) type;
      sb.append("?");

      /*
       *  According to JLS(http://java.sun.com/docs/books/jls/third_edition/html/typesValues.html#4.5.1):
       *  - Lower and upper can't coexist: (for instance, this is not allowed: <? extends List<String> & super MyInterface>)
       *  - Multiple bounds are not supported (for instance, this is not allowed: <? extends List<String> & MyInterface>)
       */
      final Type bound;
      if (wildcardType.getLowerBounds().length != 0) {
        sb.append(" super ");
        bound = wildcardType.getLowerBounds()[0];
      } else {
        sb.append(" extends ");
        bound = wildcardType.getUpperBounds()[0];
      }
      typeToString(sb, bound, visited);
    } else if (type instanceof TypeVariable<?>) {
      TypeVariable<?> typeVariable = (TypeVariable<?>) type;
      sb.append(typeVariable.getName());
      /*
       * Prevent cycles in case: <T extends List<T>>
       */
      if (!visited.contains(type)) {
        visited.add(type);
        sb.append(" extends ");
        boolean first = true;
        for (Type bound : typeVariable.getBounds()) {
          if (first) {
            first = false;
          } else {
            sb.append(" & ");
          }
          typeToString(sb, bound, visited);
        }
        visited.remove(type);
      }
    } else if (type instanceof GenericArrayType) {
      GenericArrayType genericArrayType = (GenericArrayType) type;
      typeToString(genericArrayType.getGenericComponentType());
      sb.append(genericArrayType.getGenericComponentType());
      sb.append("[]");
    } else if (type instanceof Class) {
      Class<?> typeClass = (Class<?>) type;
      sb.append(typeClass.getName());
    } else {
      throw new IllegalArgumentException("Unsupported type: " + type);
    }
  }
}
{% endhighlight %}

### Class Field
{% highlight java %}
import java.lang.reflect.Field;
import java.lang.reflect.Type;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class FieldType<K extends Number, V extends List<String> & Collection<String>> {
  List fRaw;

  List<Object> fTypeObject;

  List<String> fTypeString;

  List<?> fWildcard;

  List<? super List<String>> fBoundedWildcard;

  Map<String, List<Set<Long>>> fTypeNested;

  Map<K, V> fTypeLiteral;

  K[] fGenericArray;

  public static void main(String[] args) {
    for (Field field : FieldType.class.getDeclaredFields()) {
      Type type = field.getGenericType();
      System.out.println(field.getName() + " - " + Generics.typeToString(type));
    }
  }
}
{% endhighlight %}

Output:

~~~~~
fRaw - java.util.List
fTypeObject - java.util.List<java.lang.Object>
fTypeString - java.util.List<java.lang.String>
fWildcard - java.util.List<? extends java.lang.Object>
fBoundedWildcard - java.util.List<? super java.util.List<java.lang.String>>
fTypeNested - java.util.Map<java.lang.String>, <java.util.List<java.util.Set<java.lang.Long>>>
fTypeLiteral - java.util.Map<K extends java.lang.Number>, <V extends java.util.List<java.lang.String> & java.util.Collection<java.lang.String>>
fGenericArray - K[]
~~~~~

Above sample demonstrates interesting fact: generic type information is
available for full depth.

### Method Return Type
{% highlight java %}
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.util.List;

public class MethodReturnType {
  List mRaw() { return null; }

  List<String> mTypeString() { return null; }

  List<?> mWildcard() { return null; }

  List<? extends Number> mBoundedWildcard() { return null; }

  <T extends List<String>> List<T> mTypeLiteral() { return null; }

  public static void main(String[] args) {
    for (Method method : MethodReturnType.class.getDeclaredMethods()) {
      Type type = method.getGenericReturnType();
      System.out.println(method.getName() + " - " + Generics.typeToString(type));
    }
  }
}
{% endhighlight %}

Output:

~~~~~
mRaw - java.util.List
mTypeString - java.util.List<java.lang.String>
mWildcard - java.util.List<? extends java.lang.Object>
mBoundedWildcard - java.util.List<? extends java.lang.Number>
mTypeLiteral - java.util.List<T extends java.util.List<java.lang.String>>
~~~~~

### Method Parameter Type
{% highlight java %}
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.util.List;

public class MethodParameterType {
  <T extends List<T>> void m(String p1, T p2, List<?> p3, List<T> p4) { }

  public static void main(String[] args) {
    for (Method method : MethodParameterType.class.getDeclaredMethods()) {
      for (Type type : method.getGenericParameterTypes()) {
        System.out.println(method.getName() + " - " + Generics.typeToString(type));
      }
    }
  }
}
{% endhighlight %}

Output:

~~~~~
m - java.lang.String
m - T extends java.util.List<T>
m - java.util.List<? extends java.lang.Object>
m - java.util.List<T extends java.util.List<T>>
~~~~~

These techniques are useful if you are going to implement something that requires comprehensive meta information. Like bean property type conversion in Spring or data binding tool.

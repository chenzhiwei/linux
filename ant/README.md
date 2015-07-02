# Java Ant 构建工具使用方法

Ant 是一个用来构建 Java 程序的工具，和 make 与 C 语言的关系差不多。主要用来简化一系列操作的，通常编译 Java 程序你需要创建相关目录，添加第三方依赖，编译并生成相应的包文件。很多时候这些步骤之间还有依赖关系等等，如果手动操作的话会非常麻烦，这时就应该让 Ant 上场。即使这样，我还是不喜欢 Ant ，因为我压根对 Java 无爱。

## 安装配置 Ant

关于 Ant 的安装我就不多说了，有一点需要说明的是使用 Ant 之前你必须要安装 JDK 并配置好 JAVA_HOME 目录。

## build.xml 文件

我日，为毛要用 xml 格式，这是个非常非常垃圾的文件格式。这个 build.xml 文件就像 make 的 Makefile 文件一样，这里面定义了一些操作及其相互之间的依赖关系。

```
<?xml version="1.0" encoding="UTF-8" ?>
<project name="restapi" default="run" basedir=".">

<!-- property is variable definition -->
<property name="src" value="restapi"/>
<property name="dest" value="classes"/>
<property name="restapi_jar" value="restapi.jar"/>
<property name="common_lib" value="/home/zhiwei/java_libs"/>

<!-- Third-party libs -->
<path id="classpath">
<fileset dir="${common_lib}">
<include name="*.jar"/>
</fileset>
</path>

<target name="init">
   <mkdir dir="${dest}"/>
</target>

<target name="compile" depends="init">
   <javac includeantruntime="false" srcdir="${src}" destdir="${dest}">
    <classpath refid="classpath"/>
   </javac>
</target>

<target name="build" depends="compile">
   <jar jarfile="${restapi_jar}" basedir="${dest}"/>
</target>

<target name="copy_libs">
  <copy todir="${lib.dir}" overwrite="true">
    <fileset dir="${common_lib}">
      <include name="*.jar"/>
    </fileset>
  </copy>
</target>

<target name="archive" depends="compile, copy_libs">
    <war destfile="restapi.war">
        <fileset dir="${dst.dir}"/>
    </war>
</target>

<target name="run" depends="build">
   <java classname="com.project.restapi.Run" classpath="${restapi_jar}"/>
</target>

<target name="clean">
   <delete dir="${dest}" />
   <delete file="${restapi_jar}" />
</target>

<target name="rerun" depends="clean, run">
   <ant target="clean" />
   <ant target="run" />
</target>

</project>
```

每一个`target`都可以用`ant target`来调用，从文件第二行可以看出，默认`ant`命令调用的是`run`这个 target 。

你的这个 Java 项目可能会依赖很多第三方的`.jar`包，你需要在编译项目时将它们加到`classpath`里。

## 开始构建

在`build.xml`同级目录直接运行`ant build`就会构建出一个`restapi.jar`包，拿着这个包去做你想做的事情吧。

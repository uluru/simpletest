<?xml version="1.0"?>
<page title="Mock objects documentation" here="Mock objects">
    <long_title>SimpleTest for PHP mock objects documentation</long_title>
    <content>
        <p>
            <a class="target" name="what"><h2>What are mock objects?</h2></a>
        </p>
        <p>
            Mock objects have two roles during a test case: actor and critic.
        </p>
        <p>
            The actor behaviour is to simulate objects that are difficult to
            set up or time consuming to set up for a test.
            The classic example is a database connection.
            Setting up a test database at the start of each test would slow
            testing to a crawl and would require the installation of the
            database engine and test data on the test machine.
            If we can simulate the connection and return data of our
            choosing we not only win on the pragmatics of testing, but can
            also feed our code spurious data to see how it responds.
            We can simulate databases being down or other extremes
            without having to create a broken database for real.
            In other words, we get greater control of the test environment.
        </p>
        <p>
            If mock objects only behaved as actors they would simply be
            known as <a local="server_stubs_documentation">server stubs</a>.
        </p>
        <p>
            However, the mock objects not only play a part (by supplying chosen
            return values on demand) they are also sensitive to the
            messages sent to them (via expectations).
            By setting expected parameters for a method call they act
            as a guard that the calls upon them are made correctly.
            If expectations are not met they save us the effort of
            writing a failed test assertion by performing that duty on our
            behalf.
            In the case of an imaginary database connection they can
            test that the query, say SQL, was correctly formed by
            the object that is using the connection.
            Set them up with fairly tight expectations and you will
            hardly need manual assertions at all.
        </p>
        <p>
            <a class="target" name="creation"><h2>Creating mock objects</h2></a>
        </p>
        <p>
            In the same way that we create server stubs, all we need is an
            existing class, say a database connection that looks like this...
<php><![CDATA[
<strong>class DatabaseConnection {
    function DatabaseConnection() {
    }
    function query() {
    }
    function selectQuery() {
    }
}</strong>
]]></php>
            The class does not need to have been implemented yet.
            To create a mock version of the class we need to include the
            mock object library and run the generator...
<php><![CDATA[
<strong>require_once('simpletest/unit_tester.php');
require_once('simpletest/mock_objects.php');
require_once('database_connection.php');

Mock::generate('DatabaseConnection');</strong>
]]></php>
            This generates a clone class called
            <code>MockDatabaseConnection</code>.
            We can now create instances of the new class within
            our test case...
<php><![CDATA[
require_once('simpletest/unit_tester.php');
require_once('simpletest/mock_objects.php');
require_once('database_connection.php');

Mock::generate('DatabaseConnection');
<strong>
class MyTestCase extends UnitTestCase {
    function MyTestCase() {
        $this->UnitTestCase('My test');
    }
    function testSomething() {
        $connection = &new MockDatabaseConnection($this);
    }
}</strong>
]]></php>
            Unlike the generated stubs the mock constructor needs a reference
            to the test case so that it can dispatch passes and failures while
            checking it&apos;s expectations.
            This means that mock objects can only be used within test cases.
            Despite this their extra power means that stubs are hardly ever used
            if mocks are available.
            By always using mocks you gain greater uniformity and when
            you need the simulation objects to perform tests for you there
            is then no need to change the code.
        </p>
        <p>
            <a class="target" name="stub"><h2>Mocks as actors</h2></a>
        </p>
        <p>
            The mock version of a class has all the methods of the original
            so that operations like
            <code><![CDATA[$connection->query()]]></code> are still
            legal.
            As with stubs we can replace the default null return values...
<php><![CDATA[
<strong>$connection->setReturnValue('query', 37);</strong>
]]></php>
            Now every time we call
            <code><![CDATA[$connection->query()]]></code> we get
            the result of 37.
            As with the stubs we can set wildcards and we can overload the
            wildcard parameter.
            We can also add extra methods to the mock when generating it
            and choose our own class name...
<php><![CDATA[
<strong>Mock::generate('DatabaseConnection', 'MyMockDatabaseConnection', array('setOptions'));</strong>
]]></php>
            Here the mock will behave as if the <code>setOptions()</code>
            existed in the original class.
            This is handy if a class has used the PHP <code>overload()</code>
            mechanism to add dynamic methods.
            You can create a special mock to simulate this situation.
        </p>
        <p>
            All of the patterns available with server stubs are available
            to mock objects...
<php><![CDATA[
class Iterator {
    function Iterator() {
    }
    function next() {
    }
}
]]></php>
            Again, assuming that this iterator only returns text until it
            reaches the end, when it returns false, we can simulate it
            with...
<php><![CDATA[
Mock::generate('Iterator');

class IteratorTest extends UnitTestCase() {
    function IteratorTest() {
        $this->UnitTestCase();
    }
    function testASequence() {<strong>
        $iterator = &new MockIterator($this);
        $iterator->setReturnValue('next', false);
        $iterator->setReturnValueAt(0, 'next', 'First string');
        $iterator->setReturnValueAt(1, 'next', 'Second string');</strong>
        ...
    }
}
]]></php>
            When <code>next()</code> is called on the
            mock iterator it will first return &quot;First string&quot;,
            on the second call &quot;Second string&quot; will be returned
            and on any other call <code>false</code> will
            be returned.
            The sequenced return values take precedence over the constant
            return value.
            The constant one is a kind of default if you like.
        </p>
        <p>
            A repeat of the stubbed information holder with name/value pairs...
<php><![CDATA[
class Configuration {
    function Configuration() {
    }
    function getValue($key) {
    }
}
]]></php>
            This is a classic situation for using mock objects as
            actual configuration will vary from machine to machine,
            hardly helping the reliability of our tests if we use it
            directly.
            The problem though is that all the data comes through the
            <code>getValue()</code> method and yet
            we want different results for different keys.
            Luckily the mocks have a filter system...
<php><![CDATA[
<strong>$config = &new MockConfiguration($this);
$config->setReturnValue('getValue', 'primary', array('db_host'));
$config->setReturnValue('getValue', 'admin', array('db_user'));
$config->setReturnValue('getValue', 'secret', array('db_password'));</strong>
]]></php>
            The extra parameter is a list of arguments to attempt
            to match.
            In this case we are trying to match only one argument which
            is the look up key.
            Now when the mock object has the
            <code>getValue()</code> method invoked
            like this...
<php><![CDATA[
$config->getValue('db_user')
]]></php>
            ...it will return &quot;admin&quot;.
            It finds this by attempting to match the calling arguments
            to it&apos;s list of returns one after another until
            a complete match is found.
        </p>
        <p>
            There are times when you want a specific object to be
            dished out by the mock rather than a copy.
            Again this is identical to the server stubs mechanism...
<php><![CDATA[
class Thing {
}

class Vector {
    function Vector() {
    }
    function get($index) {
    }
}
]]></php>
            In this case you can set a reference into the mock&apos;s
            return list...
<php><![CDATA[
$thing = new Thing();<strong>
$vector = &new MockVector($this);
$vector->setReturnReference('get', $thing, array(12));</strong>
]]></php>
            With this arrangement you know that every time
            <code><![CDATA[$vector->get(12)]]></code> is
            called it will return the same
            <code>$thing</code> each time.
        </p>
        <p>
            <a class="target" name="expectations"><h2>Mocks as critics</h2></a>
        </p>
        <p>
            Although the server stubs approach insulates your tests from
            real world disruption, it is only half the benefit.
            You can have the class under test receiving the required
            messages, but is your new class sending correct ones?
            Testing this can get messy without a mock objects library.
        </p>
        <p>
            By way of example, suppose we have a
            <code>SessionPool</code> class that we
            want to add logging to.
            Rather than grow the original class into something more
            complicated, we want to add this behaviour with a decorator (GOF).
            The <code>SessionPool</code> code currently looks
            like this...
<php><![CDATA[
<strong>class SessionPool {
    function SessionPool() {
        ...
    }
    function &findSession($cookie) {
        ...
    }
    ...
}

class Session {
    ...
}</strong>
</pre>
                While our logging code looks like this...
<pre><strong>
class Log {
    function Log() {
        ...
    }
    function message() {
        ...
    }
}

class LoggingSessionPool {
    function LoggingSessionPool(&$session_pool, &$log) {
        ...
    }
    function &findSession(\$cookie) {
        ...
    }
    ...
}</strong>
]]></php>
            Out of all of this, the only class we want to test here
            is the <code>LoggingSessionPool</code>.
            In particular we would like to check that the
            <code>findSession()</code> method is
            called with the correct session ID in the cookie and that
            it sent the message &quot;Starting session $cookie&quot;
            to the logger.
        </p>
        <p>
            Despite the fact that we are testing only a few lines of
            production code, here is what we would have to do in a
            conventional test case:
            <ol>
                <li>Create a log object.</li>
                <li>Set a directory to place the log file.</li>
                <li>Set the directory permissions so we can write the log.</li>
                <li>Create a <code>SessionPool</code> object.</li>
                <li>Hand start a session, which probably does lot&apos;s of things.</li>
                <li>Invoke <code>findSession()</code>.</li>
                <li>Read the new Session ID (hope there is an accessor!).</li>
                <li>Raise a test assertion to confirm that the ID matches the cookie.</li>
                <li>Read the last line of the log file.</li>
                <li>Pattern match out the extra logging timestamps, etc.</li>
                <li>Assert that the session message is contained in the text.</li>
            </ol>
            It is hardly surprising that developers hate writing tests
            when they are this much drudgery.
            To make things worse, every time the logging format changes or
            the method of creating new sessions changes, we have to rewrite
            parts of this test even though this test does not officially
            test those parts of the system.
            We are creating headaches for the writers of these other classes.
        </p>
        <p>
            Instead, here is the complete test method using mock object magic...
<php><![CDATA[
Mock::generate('Session');
Mock::generate('SessionPool');
Mock::generate('Log');

class LoggingSessionPoolTest extends UnitTestCase {
    ...
    function testFindSessionLogging() {<strong>
        $session = &new MockSession($this);
        $pool = &new MockSessionPool($this);
        $pool->setReturnReference('findSession', $session);
        $pool->expectOnce('findSession', array('abc'));
        
        $log = &new MockLog($this);
        $log->expectOnce('message', array('Starting session abc'));
        
        $logging_pool = &new LoggingSessionPool($pool, $log);
        $this->assertReference($logging_pool->findSession('abc'), $session);
        $pool->tally();
        $log->tally();</strong>
    }
}
]]></php>
            We start by creating a dummy session.
            We don&apos;t have to be too fussy about this as the check
            for which session we want is done elsewhere.
            We only need to check that it was the same one that came
            from the session pool.
        </p>
        <p>
            <code>findSession()</code> is a factory
            method the simulation of which is described <a href="#stub">above</a>.
            The point of departure comes with the first
            <code>expectOnce()</code> call.
            This line states that whenever
            <code>findSession()</code> is invoked on the
            mock, it will test the incoming arguments.
            If it receives the single argument of a string &quot;abc&quot;
            then a test pass is sent to the unit tester, otherwise a fail is
            generated.
            This was the part where we checked that the right session was asked for.
            The argument list follows the same format as the one for setting
            return values.
            You can have wildcards and sequences and the order of
            evaluation is the same.
        </p>
        <p>
            If the call is never made then neither a pass nor a failure will
            generated.
            To get around this we must tell the mock when the test is over
            so that the object can decide if the expectation has been met.
            The unit tester assertion for this is triggered by the
            <code>tally()</code> call at the end of
            the test.
        </p>
        <p>
            We use the same pattern to set up the mock logger.
            We tell it that it should have
            <code>message()</code> invoked
            once only with the argument &quot;Starting session abc&quot;.
            By testing the calling arguments, rather than the logger output,
            we insulate the test from any display changes in the logger.
        </p>
        <p>
            We start to run our tests when we create the new
            <code>LoggingSessionPool</code> and feed
            it our preset mock objects.
            Everything is now under our control.
            Finally we confirm that the
            <code>$session</code> we gave our decorator
            is the one that we get back and tell the mocks to run their
            internal call count tests with the
            <code>tally()</code> calls.
        </p>
        <p>
            This is still quite a bit of test code, but the code is very
            strict.
            If it still seems rather daunting there is a lot less of it
            than if we tried this without mocks and this particular test,
            interactions rather than output, is always more work to set
            up.
            More often you will be testing more complex situations without
            needing this level or precision.
            Also some of this can be refactored into a test case
            <code>setUp()</code> method.
        </p>
        <p>
            Here is the full list of expectations you can set on a mock object
            in <a href="http://www.lastcraft.com/simple_test.php">SimpleTest</a>...
            <table>
                <tr><th>Expectation</th><th>Needs <code>tally()</code></th></tr>
                <tr>
                    <td><code>expectArguments($method, $args)</code></td>
                    <td style="text-align: center">No</td>
                </tr>
                <tr>
                    <td><code>expectArgumentsAt($timing, $method, $args)</code></td>
                    <td style="text-align: center">No</td>
                </tr>
                <tr>
                    <td><code>expectCallCount($method, $count)</code></td>
                    <td style="text-align: center">Yes</td>
                </tr>
                <tr>
                    <td><code>expectMaximumCallCount($method, $count)</code></td>
                    <td style="text-align: center">No</td>
                </tr>
                <tr>
                    <td><code>expectMinimumCallCount($method, $count)</code></td>
                    <td style="text-align: center">Yes</td>
                </tr>
                <tr>
                    <td><code>expectNever($method)</code></td>
                    <td style="text-align: center">No</td>
                </tr>
                <tr>
                    <td><code>expectOnce($method, $args)</code></td>
                    <td style="text-align: center">Yes</td>
                </tr>
                <tr>
                    <td><code>expectAtLeastOnce($method, $args)</code></td>
                    <td style="text-align: center">Yes</td>
                </tr>
            </table>
            Where the parameters are...
            <dl>
                <dt class="new_code">$method</dt>
                <dd>The method name, as a string, to apply the condition to.</dd>
                <dt class="new_code">$args</dt>
                <dd>
                    The arguments as a list. Wildcards can be included in the same
                    manner as for <code>setReturn()</code>.
                    This argument is optional for <code>expectOnce()</code>
                    and <code>expectAtLeastOnce()</code>.
                </dd>
                <dt class="new_code">$timing</dt>
                <dd>
                    The only point in time to test the condition.
                    The first call starts at zero.
                </dd>
                <dt class="new_code">$count</dt>
                <dd>The number of calls expected.</dd>
            </dl>
            The method <code>expectMaximumCallCount()</code>
            is slightly different in that it will only ever generate a failure.
            It is silent if the limit is never reached.
        </p>
        <p>
            <a class="target" name="approaches"><h2>Other approaches</h2></a>
        </p>
        <p>
            There are three approaches to creating mocks.
            Coding them by hand using a base class, generating them to
            a file and dynamically generating them on the fly.
        </p>
        <p>
            Mock objects generated with <a local="simple_test">SimpleTest</a>
            are dynamic.
            They are created at run time in memory, using
            <code>eval()</code>, rather than written
            out to a file.
            This makes the mocks easy to create, a one liner, especially compared with hand
            crafting them in a parallel class hierarchy.
            The problem is that the behaviour is usually set up in the tests
            themselves.
            If the original objects change the mock versions
            that the tests rely on can get out of sync.
            This can happen with the parallel hierarchy approach as well,
            but is far more quickly detected.
        </p>
        <p>
            The solution, of course, is to add some real integration
            tests.
            You don&apos;t need very many and the convenience gained
            from the mocks more than outweighs the small amount of
            extra testing.
        </p>
        <p>
            If you are still determined to build libraries of mocks, you can
            achieve the same effect.
            In your library file, say <em>mocks/connection.php</em> for a
            database connection, create a mock and inherit to override
            special methods or add presets...
<php><![CDATA[
<?php
    require_once('simpletest/mock_objects.php');
    require_once('../classes/connection.php');
<strong>
    Mock::generate('Connection', 'BasicMockConnection');
    class MockConnection extends BasicMockConnection {
        function MockConnection(&$test, $wildcard = '*') {
            $this->BasicMockConnection($test, $wildcard);
            $this->setReturn('query', false);
        }
    }</strong>
?>
]]></php>
            The generate call tells the class generator to create
            a class called <code>BasicMockConnection</code>
            rather than the usual <code>MockConnection</code>.
            We then inherit from this to get our version of
            <code>MockConnection</code>.
            By intercepting in this way we can add behaviour, here setting
            the default value of <code>query()</code> to be false.
            By using the default name we make sure that the mock class
            generator will not recreate a different one when invoked elsewhere in the
            tests.
            It never creates a class if it already exists.
            As long as the above file is included first then all tests
            that generated <code>MockConnection</code> should
            now be using our one instead.
            If we don&apos;t get the order right and the mock library
            creates one first then the class creation will simply fail.
        </p>
        <p>
            Use this trick if you find you have a lot of common mock behaviour
            or you are getting frequent integration problems at later
            stages of testing.
        </p>
        <p>
            <a class="target" name="other_testers"><h2>I think SimpleTest stinks!</h2></a>
        </p>
        <p>
            But at the time of writing it is the only one with mock objects,
            so are you stuck with it?
        </p>
        <p>
            No, not at all.
            <a local="simple_test">SimpleTest</a> is a toolkit and one of those
            tools is the mock objects which can be employed independently.
            Suppose you have your own favourite unit tester and all your current
            test cases are written using it.
            Pretend that you have called your unit tester PHPUnit (everyone else has)
            and the core test class looks like this...
<php><![CDATA[
class PHPUnit {
    function PHPUnit() {
    }
    function assertion($message, $assertion) {
    }
    ...
}
]]></php>
            All the <code>assertion()</code> method does
            is print some fancy output and the boolean assertion parameter determines
            whether to print a pass or a failure.
            Let&apos;s say that it is used like this...
<php><![CDATA[
$unit_test = new PHPUnit();
$unit_test>assertion('I hope this file exists', file_exists('my_file'));
]]></php>
            How do you use mocks with this?
        </p>
        <p>
            There is a protected method on the base mock class
            <code>SimpleMock</code> called
            <code>_assertTrue()</code> and
            by overriding this method we can use our own assertion format.
            We start with a subclass, in say <em>my_mock.php</em>...
<php><![CDATA[
<strong><?php
    require_once('simpletest/mock_objects.php');
    
    class MyMock extends SimpleMock() {
        function MyMock(&$test, $wildcard) {
            $this->SimpleMock($test, $wildcard);
        }
        function _assertTrue($assertion, $message , &$test) {
            $test->assertion($message, $assertion);
        }
    }
?></strong>
]]></php>
            Now instantiating <code>MyMock</code> will create
            an object that speaks the same language as your tester.
            The catch is of course that we never create such an object, the
            code generator does.
            We need just one more line of code to tell the generator to use
            your mock instead...
<php><![CDATA[
<?php
    require_once('simpletst/mock_objects.php');
    
    class MyMock extends SimpleMock() {
        function MyMock($test, $wildcard) {
            $this->SimpleMock(&$test, $wildcard);
        }
        function _assertTrue($assertion, $message , &$test) {
            $test->assertion($message, $assertion);
        }
    }<strong>
    SimpleTestOptions::setMockBaseClass('MyMock');</strong>
?>
]]></php>
            From now on you just include <em>my_mock.php</em> instead of the
            default <em>simple_mock.php</em> version and you can introduce
            mock objects into your existing test suite.
        </p>
    </content>
    <internal>
        <link>
            <a href="#what">What are mock objects?</a>
        </link>
        <link>
            <a href="#creation">Creating mock objects</a>.
        </link>
        <link>
            <a href="#stub">Mocks as actors</a> or stubs.
        </link>
        <link>
            <a href="#expectations">Mocks as critics</a> with expectations.
        </link>
        <link>
            <a href="#approaches">Other approaches</a> including mock libraries.
        </link>
        <link>
            Using mocks with <a href="#other_testers">other unit testers</a>.
        </link>
    </internal>
    <external>
        <link>
            The original
            <a href="http://www.mockobjects.com/">Mock objects</a> paper.
        </link>
        <link>
            SimpleTest project page on <a href="http://sourceforge.net/projects/simpletest/">SourceForge</a>.
        </link>
        <link>
            SimpleTest home page on <a href="http://www.lastcraft.com/simple_test.php">LastCraft</a>.
        </link>
    </external>
    <meta>
        <keywords>
            software development,
            php programming,
            programming php,
            software development tools,
            php tutorial,
            free php scripts,
            architecture,
            php resources,
            mock objects,
            junit,
            php testing,
            unit test,
            php testing
        </keywords>
    </meta>
</page>
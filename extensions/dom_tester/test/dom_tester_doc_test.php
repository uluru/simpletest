<?php
// $Id$
require_once dirname(__FILE__) . '/../../../autorun.php';
require_once dirname(__FILE__) . '/../../dom_tester.php';

SimpleTest :: prefer(new TextReporter());

class TestOfLiveCssSelectors extends DomTestCase {
    function setUp() {
        $this->addHeader('User-Agent: SimpleTest ' . SimpleTest::getVersion());
    }
    
    function testGet() {
        $url = 'http://simpletest.org/';
        $this->assertTrue($this->get($url));
        $this->assertEqual($this->getUrl(), $url);
        $this->assertEqual($this->getElementsBySelector('h2'), array('Screenshots', 'Documentation', 'Contributing'));
        $this->assertElementsBySelector('h2', array('Screenshots', 'Documentation', 'Contributing'));
		$this->assertElementsBySelector('a[href="http://simpletest.org/api/"]', array('the complete API', 'documented API'));
   		$this->assertElementsBySelector('div#content > p > strong', array('SimpleTest PHP unit tester'));
    }
}

?>
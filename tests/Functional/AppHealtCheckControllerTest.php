<?php

declare(strict_types=1);

namespace App\Tests\Functional;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class AppHealtCheckControllerTest extends WebTestCase
{
    public function testHeatCheck()
    {
        $client = static::createClient();

        $client->request('GET', '/sys/healt/check');

        $this->assertResponseIsSuccessful();
    }
}

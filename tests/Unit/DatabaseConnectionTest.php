<?php

namespace Tests\Unit;

use Tests\TestCase;

class DatabaseConnectionTest extends TestCase
{
    public function test_phpunit_uses_dedicated_testing_database(): void
    {
        $this->assertSame(
            'kampala_nonstop_testing',
            config('database.connections.pgsql.database'),
            'PHPUnit must not use the shared development database.'
        );
    }
}

<?php

declare(strict_types=1);

/*
 * Docker compose injects DB_DATABASE into the process environment. PHPUnit <env>
 * values do not always override that, so force the dedicated testing database
 * before Laravel boots.
 */
putenv('DB_DATABASE=kampala_nonstop_testing');
$_ENV['DB_DATABASE'] = 'kampala_nonstop_testing';
$_SERVER['DB_DATABASE'] = 'kampala_nonstop_testing';

require __DIR__.'/../vendor/autoload.php';

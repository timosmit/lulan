<?php

declare(strict_types=1);

if (php_sapi_name() !== 'cli-server') {
	ini_set('display_errors', 'off');
}

$config = @array_replace_recursive(
	require(__DIR__ . '/config.dist.php'),
	@include(__DIR__ . '/config.php')
);

if ($config === null) {
	lulan_install();
	exit;
}

if (!empty($config['password'])) {

	// Prevents from conflicting between multiple installations within the
	// same domain, also forces re-login whenever the password is changed.
	$installation = 'lulan_' . substr(sha1(__FILE__ . '#' . ($config['password'] ?? '')), 0, 6);

	if (session_status() === PHP_SESSION_NONE) {
		session_name($installation);
		session_start();
	}

	if (empty($_SESSION[$installation])) {
		if (lulan_login()) {
			$_SESSION[$installation] = true;
		} else {
			exit;
		}
	}

}

function lulan_header(string $title = 'LuLan')
{
	?>
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title><?= htmlspecialchars($title); ?></title>
		<link href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
	</head>
	<body>
	<div class="container-fluid">
<?php
}

function lulan_footer()
{
	?>
	</div>
	<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.bundle.min.js" integrity="sha384-xrRywqdh3PHs8keKZN+8zzc5TX0GRTLCcmivcbNJWm2rs5C8PRhcEn3czEjhAO9o" crossorigin="anonymous"></script>
	</body>
</html>
<?php
}

function lulan_main()
{
	lulan_header();
	?>
	<h1>LuLan</h1>
	<?php
	lulan_footer();
}

function lulan_login(): bool
{
	global $config;

	$error = false;

	if (($_POST['do'] ?? null) === 'login') {

		$password = $_POST['password'] ?? '';

		if ($password === $config['password'] || is_array($config['password']) && in_array($password, $config['password'], true)) {
			return true;
		}

		$error = true;

	}

	header('HTTP/1.1 401 Unauthorized');

	lulan_header('Login');

	?>
	<div class="mx-auto mt-5 text-center" style="max-width: 300px;">
		<h1>Who are you?</h1>
		<?php if($error): ?><p class="alert alert-danger">That's a wrong password!</p><?php endif; ?>
		<form method="post">
			<div class="form-group text-left">
				<label>Password</label>
				<input name="password" type="password" class="form-control<?php if($error): ?> is-invalid<?php endif; ?>">
			</div>
			<button class="btn btn-primary">Login</button>
			<input type="hidden" name="do" value="login">
		</form>
	</div>
	<?php

	lulan_footer();
	return false;
}

function lulan_install()
{
	lulan_header('Installation');
	?>
	<p><code>config.php</code> doesn't exist, or there's an error in it.</p>
	<?php
	lulan_footer();
}

register_shutdown_function(function() {

	if (!headers_sent()) {
		lulan_main();
	}

});
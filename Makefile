init:
	flutter version

test-cov:
	flutter test --coverage
	genhtml coverage/lcov.info --ignore-errors empty,empty -o coverage/html

gen:
	dart run build_runner build
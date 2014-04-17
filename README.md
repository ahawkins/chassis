# Chassis

Chassis is a collection of new classes and enhancements to existing
projects for building maintainable applications. I choose the name
"chassis" because I'm a car guy. A chassis is a car's foundation.
Every car has key components: there is an engine, transmission,
differential, suspension, electrical system, and a bunch of other
things. They fit together on the chassis in a certain way, there are
guidelines but no one is going to stop you from building a custom
front suspension on a typical chassis. And that's the point. The
chassis is there to build on. It does not make decisions for you.
There are also kit cars and longblock engines. Kit cars come with some
components and rely on you to assemble them. Longblocks are halfway
complete engines. The engine block and valve train are predecided. You
must decide which fuel delivery and exhaust system to use. Then you
mount it in the chassis. In all things there is a line between
prepackaged DIY and turn-key solutions. This project is a combination
of a chassis and long block. Some things have been predecided and
others are left to you. In that sense this project is a utility belt.
All the components are there, you just need to figure out how to put
them together.

This project chooses an ideal gem stack for building web applications
and enhancements to existing projects. It's just a enough structure to
build an application. It is the chassis you build your application on.

## Installation

Add this line to your application's Gemfile:

    gem 'chassis'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chassis

## Rack & Sinatra

Right off the bat, chassis is for building web applications. It
depends on other gems to make that happen. Chassis fully endorses rack
& Sinatra as the best way to do this. So it contains enhancements and
middleware to make that so.

* `Chassis::Rack::Bouncer` - takes a block. Used to bounce spam or
  other undesirable requests.
* `Chassis::Rack::HealthCheck` - for load balanced applications. Takes
  a block to test if the applications is ready. Failures terminate the
  process.
* `Chassis::Rack::Instrumentation` - use harness to instrument all
  request timings
* `Chassis::Rack::NoRobots` - blocks all crawlers and bots.

`Chassis::WebService` includes some of these middleware as well as
other customizations.

* requires `sinatra/json` for JSON response generation
* requires `rack/contrib/bounce_favicton` because ain't no body got
  time for that
* uses `Chassis::Rack::Bouncer`
* uses `Chassis::Rack::NoRobots`
* uses `Rack::Deflator` to gzip everything
* uses `Rack::PostBodyContentTypeParser` to parse incoming JSON bodies
* `enable :cors` to enable CORS with manifold.
* registers error handlers for unknown exceptions coming from other
  chassis components.
* other misc helpers for generating JSON and handling errors.

## Data Access

Chassis includes a
[repository](http://martinfowler.com/eaaCatalog/repository.html) using
the query pattern as well. The repository pattern is perfect because
it does not require knowledge about your persistence layer. It is the
access layer. A null, in-memory, and Redis adapter are included. You
can subclass these adapters to make your own.
`Chassis::Repo::Delegation` can be included in other classes to
delegate to the repository.

Here's an example:

```ruby
class CustomerRepo
  extend Chassis::Repo::Delegation
end
```

Now there are CRUD methods available on `CustomerRepo` that delegate
to the repository for `Customer` objects. `Chassis::Persistence` can
be included in any object. It will make the object compatible with
the matching repo.

```ruby
class Customer
  include Chassis::Persistence
end
```

Now `Customer` responds to `id`, `save`, and `repo`. `repo` looks for
a repository class matching the class name (e.g. `CustomerRepo`).
Override as you see if.

More on my blog
[here](http://hawkins.io/2014/01/pesistence_with_repository_and_query_patterns/).

## Chassis::Form

`Virtus` and `virtus-dirty_attribute` are used to create
`Chassis::Form`. It includes a few minor enhancements. All assignments
go through dirty tracking to support the partial update use case.
`Chassis::Form#values` will return a hash of everything that's been
assigned. `Chassi::Form#attributes` returns a hash for all the
declared attributes. `initialize` has been modified as well. Trying to
set an unknown attributes will raise
`Chassis::Form::UnknownFieldError` instead of `NoMethodError`.
`Chassis::WebService` registers an error handler and returns a `400
Bad Request` in this case.

Create a new form by including `Chassis.form`

```ruby
class SignupForm
  include Chassis.form
end
```

## Outgoing HTTP with Faraday

Chassis uses Faraday because it's the best god damn HTTP client in
ruby. Chassis includes a bunch of middleware to make it even better.

```ruby
Farday.new 'http://foo.com', do |builder|
  # Every request is timed with Harness into a namespaced key.
  # You can pass a namespace as the second argument: IE "twilio",
  # or "sendgrid"
  faraday.request :instrumentation

  # Send requests with `content-type: application/json` and use
  # the standard library JSON to encode the body
  faraday.request :encode_json

  # Parse a JSON response into a hash
  faraday.request :parse_json

  # This is the most important one IMO. All requests 4xx and 5xx
  # requests will raise a useful error with the response body
  # and status code. This is much more useful than the bundled
  # implementation. A 403 response will raise a HttpForbiddenError.
  # This middleware also captures timeouts.
  # Useful for catching failure conditions.
  faraday.request :server_error_handler

  # Log all requests and responses. Useful when debugging running
  # applications
  faraday.response :logging
end
```

There is also a faraday factory that will build new connections using
this middleware stack.

```ruby
# Just like normal, but the aforementioned middleware included.
# Any middleware you insert will come after the chassis ones.

Chassis.faraday 'http://foo.com' do |builder|
  # your stuff here
end
```

## Circuit Breakers with Breaker

[Breaker](https://github.com/ahawkins/breaker) provides the low level
implementation. `Chassis::CircuitPanel` is a class for unifying
access to all the different circuits in the application. This is
useful because other parts of the code don't need to know about how
the circuit is implemented. `Chassis.circuit_panel` behaves like
`Struct.new`. It returns a new class.

```ruby
CircuitPanel = Chassis.circuit_panel do
  circuit :test, timeout: 10, retry_threshold: 6
end

panel = CircuitPanel.new

circuit = panel.test
circuit.class # => Breaker::Circuit

circuit.run do
  # do your stuff here
end
```

Since `Chassis.circuit_panel` returns a class, you can do anything you
want. Don't like to have to instantiate a new instance every time? Use
a singleton and assign that to a constant.

```ruby
require 'singleton'

CircuitPanel = Chassis.circuit_panel do
  include Singleton

  circuit :test, timeout: 10, retry_threshold: 6
end.instance

CircuitPanel.test.run do
  # your stuff here
end
```

## Chassis::Strategy

`Chassis::Strategy` is a way to define boundary objects. The class
defines the all required methods, then delegates the work to an
implementation. Implementations are be registered and used. A null
object implementation is automatically generated and set as the
default implementation. Here are some examples.

```ruby
class Mailer
  include Chassis.strategy(:deliver, :deliveries)
end

class SMTPDelivery
  def deliver(mail)
    # send w/SMTP
  end

  def deliveries
    # check the email account
  end
end

class SnailMail
  def deliver(mail)
    # print the mail and go to the post office
  end

  def deliveries
    # go outside and check the mailbox
  end
end

mailer = Mailer.new
mailer.register :smtp, SMTPDelivery.new
mailer.register :snail_mail, SnailMail.new

mail.use :smtp
mail.deliver some_message

mail.use :null # switch back to the null implementation.
```

These objects are very useful when you have an interaction that needs
to happen but implementations can vary widely. You can also use this
as class if you don't like the instance flavor.

```ruby
class Mailer
  extend Chassis.strategy(:foo, :bar, :bar)
end

Mailer.register, :smtp, SomeSmtpClass
```

Since `Chassis.strategy` returns a new module, you can call define
methods and call `super` just like normal.

```ruby
class Mailer
  include Chassis.strategy(:deliver)

  def deliver(mail)
    raise "No address" unless mail.to
    super
  end
end
```

This is great when you have some shared logic at the boundary but not
across implementations.

## Chassis::DirtySession

A proxy object used to track assignments. Wrap an object in a dirty
session to see what changed and what it changed to.

```ruby
Person = Struct.new :name

adam = Person.new 'adam'

session = Chassis::DirtySession.new adam
session.clean? # => true
session.dirty? # => false

session.name = 'Adman'

session.dirty? # => true
session.clean? # => false

session.named_changed? # => true
session.changed # => set of values changed
session.new_values # => { name: 'Adman' }
session.original_values # => { name: 'adam' }

session.reset! # reset everything back to normal
```

## Chassis::Logger

Chassis includes the `logger-better` gem to refine the standard
library logger. `Chassis::Logger` default the `logdev` argument to
`Chassis.stream`. This gives a unified place to assign all output.
The log level can also be controlled by the `LOG_LEVEL` environment
variable. This makes it possible to restart/boot the application with
a new log level without redeploying code.

## Chassis::Observable

A very simple implementation of the observer pattern. It is different
from the standard library implementation for two reasons:

* you don't need to call `changed` for `notify_observers` to work.
* `notify_obsevers` includes `self` as first argument to all observers
* there is only the `add_observer` method.

## Chassis::Initializable

Encapsulate the common pattern of passing a hash for assignments to
`initialize`. A block can be given as well.


```ruby
class Person
  include Chassis::Initializable

  attr_accessor :name, :email
end

Person.new name: 'adam', email: 'example@example.com'

Person.new name: 'adam' do |adam|
  adam.email = 'example@example.com'
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

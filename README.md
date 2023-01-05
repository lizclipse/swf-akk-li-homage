# A faithful homage to swf.akk.li

This is something from early highschool that I remember spending a ton of time refreshing, and I was sad to see that it had been taken down. Using [archive.org](https://archive.org), I've sourced most of the SWFs and the original page and rebuilt it as close to the original as possible.

Some of them don't work any more due to either the use of ActionScript 3 or some unsupported features, and roughly 1/3 are missing (according to the available URLs on archive.org). Eventually, I would like to get it back to parity. There are some limitations due to some modern browsers not allowing audio autoplay and requiring an emulator, but it's otherwise fairly close.

## Development

This is built on AWS using Lambda, API Gateway V2, & S3, and deployed using Terraform. Service choice is mostly due to cost, these services cost virually nothing to have no requests, and can handle millions for pennies. Terraform is used mostly to learn and flesh my skill out, but also because I'd be too lazy to maintain this thing otherwise.

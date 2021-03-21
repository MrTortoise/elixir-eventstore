# EventStore

## Description

- This is an eventstore built a bit differently.
- Most of the time we access event stores by their aggregate or stream id.
  - we are also operating upon the assumption of many very small streams
  - also assuming that old streams can be closed off (etier deleted or just replaced with a snapshot)

However traditionally events are stored against an event log and then indexed by streams and projections.

Here we are going to maintain an event log.

- essentially as that classic antipattern in a distributed system to generate a sequence of id's locally.
- if we ever get distributed we can incorporate node id and play about that way.

## Architecture ideas
 
### The global stream

It is *very* useful to have global ordering of events as when projecting over the past accross multiple streams we need to know this sequence.
This is done on any projection. As a result most of these systems store events in a global stream and then thing slike streams and projections index into them.

Here I wanted to try something different and make the stream the first class storage unit - the global stream simply being a side effect.
My gut feel is that this will aid far better in a distributed environment.

The first iteration had projections as simply being another stream - this meant that the events were being copied into another stream. I actually really liked this, but cannot help but think the storage overhead is a little much. Eg when you consider the global stream being necessary you are writing each event at least twice - and implicitly more because projections.

So we are going to take probably a big hit on read - and memory! and do projections as indexes

### How to partition and index?

1. Store events in the streams they are written as because
1.1. This is probably most common mode of access
1.2. The assumption is that data cleanup is determined by the lifecycle of the stream (The usual problem of downstream reports exists - here we get into whether these are a seperate domain boundary)

2. Projections are a seperate process to writing events.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `event_store` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:event_store, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/event_store](https://hexdocs.pm/event_store).


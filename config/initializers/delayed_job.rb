require 'delayed_job'

Delayed::Worker.backend = :active_record
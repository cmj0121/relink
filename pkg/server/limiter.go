package server

import (
	"sync"
	"time"

	"github.com/rs/zerolog/log"
)

type RateLimiter struct {
	Threshold int
	Sentence  time.Duration

	mu sync.Mutex

	// the jail map to store the IP address and the time
	jail map[string]time.Time
	// the counter map to store the IP address and the count
	counter map[string]int
}

func NewLimiter() *RateLimiter {
	return &RateLimiter{
		Threshold: 3,
		Sentence:  5 * time.Minute,
		jail:      make(map[string]time.Time),
		counter:   make(map[string]int),
	}
}

// Count the IP address with the rate limiter and ban it if it exceeds the threshold.
func (r *RateLimiter) Ban(ip string) {
	r.mu.Lock()
	defer r.mu.Unlock()

	if !r.check(ip) {
		log.Info().Str("ip", ip).Msg("the IP address is already banned")
		return
	}

	switch count, ok := r.counter[ip]; ok {
	case true:
		r.counter[ip] = count + 1
	case false:
		r.counter[ip] = 1
	}

	if r.counter[ip] > r.Threshold {
		delete(r.counter, ip)
		r.jail[ip] = time.Now()

		log.Info().Str("ip", ip).Msg("ban the IP address")
	}
}

// Check the IP address with the rate limiter.
func (r *RateLimiter) Check(ip string) bool {
	r.mu.Lock()
	defer r.mu.Unlock()

	return r.check(ip)
}

func (r *RateLimiter) check(ip string) bool {
	switch sentence, ok := r.jail[ip]; ok {
	case false:
		return true
	case true:
		if time.Since(sentence) > r.Sentence {
			delete(r.jail, ip)
			return true
		}
	}

	return false
}

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"cloud.google.com/go/pubsub"
)

func main() {
	// Set your Google Cloud Project ID and Pub/Sub Topic
	projectID := "inventyv-project"
	topicID := "spinnaker"

	// Create a Pub/Sub client
	ctx := context.Background()
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create Pub/Sub client: %v", err)
	}
	defer client.Close()

	// Get a reference to the topic
	topic := client.Topic(topicID)

	// Create JSON message
	messageData := map[string]string{"deploy": "true"}
	jsonData, err := json.Marshal(messageData)
	if err != nil {
		log.Fatalf("Failed to marshal JSON: %v", err)
	}

	// Publish the JSON message
	result := topic.Publish(ctx, &pubsub.Message{
		Data: jsonData,
	})

	// Get the published message ID
	id, err := result.Get(ctx)
	if err != nil {
		log.Fatalf("Failed to publish message: %v", err)
	}

	fmt.Printf("Message published with ID: %s\n", id)
}

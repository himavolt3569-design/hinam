import { initializeApp } from "firebase-admin/app";
import { getFirestore, DocumentData } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";

initializeApp();

interface NotificationContent {
  title: string;
  body: string;
}

interface NotificationDecision {
  uid: string;
  notification: NotificationContent;
}

/**
 * A new offer always targets the driver it was created for.
 */
export function decideOfferCreatedNotification(
  offer: DocumentData
): NotificationDecision | null {
  const driverId = offer.driverId as string | undefined;
  if (!driverId) return null;

  return {
    uid: driverId,
    notification: {
      title: "New Ride Request",
      body: `You have a new ride request for Rs. ${offer.offerAmount}.`,
    },
  };
}

/**
 * Only the two ride-status transitions the product spec defines produce a
 * notification: a match (passenger is told a driver was found) and a
 * cancellation once a driver was already assigned (that driver is told).
 * A cancellation before any driver is matched has no counterpart to notify.
 */
export function decideStatusChangeNotification(
  before: DocumentData,
  after: DocumentData
): NotificationDecision | null {
  if (before.status === after.status) return null;

  if (after.status === "matched") {
    return {
      uid: after.passengerId,
      notification: {
        title: "Driver Assigned!",
        body: "A driver has accepted your ride request.",
      },
    };
  }

  if (after.status === "cancelled" && after.driverId) {
    return {
      uid: after.driverId,
      notification: {
        title: "Ride Cancelled",
        body: "This ride has been cancelled.",
      },
    };
  }

  return null;
}

/**
 * Looks up the recipient's token from Phase 2's fcm_tokens/{uid} and sends
 * a `notification`-payload push, which the OS displays automatically even
 * when the recipient's app is backgrounded or not running.
 */
async function notifyUser(decision: NotificationDecision): Promise<void> {
  const tokenDoc = await getFirestore()
    .collection("fcm_tokens")
    .doc(decision.uid)
    .get();
  const token = tokenDoc.data()?.token as string | undefined;

  if (!token) {
    logger.info(`No FCM token registered for uid ${decision.uid}; skipping push.`);
    return;
  }

  try {
    await getMessaging().send({ token, notification: decision.notification });
  } catch (error) {
    logger.error(`Failed to send notification to uid ${decision.uid}`, error);
  }
}

export const onOfferCreated = onDocumentCreated(
  "rides/{rideId}/offers/{offerId}",
  async (event) => {
    const offer = event.data?.data();
    if (!offer) return;

    const decision = decideOfferCreatedNotification(offer);
    if (decision) await notifyUser(decision);
  }
);

export const onRideStatusChanged = onDocumentUpdated(
  "rides/{rideId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const decision = decideStatusChangeNotification(before, after);
    if (decision) await notifyUser(decision);
  }
);

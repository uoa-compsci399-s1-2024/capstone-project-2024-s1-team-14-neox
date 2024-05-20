import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Background"),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildHeading("Our Product"),

            _buildText("""
Myopia is the most widespread eye condition in the world. Also known as near-sightedness, Myopia affects approximately 34% of the global population and is estimated to affect almost 50% by 2050. This is a staggering 5 billion people. The earlier Myopia occurs in a child's life, the more likely it will develop into high myopia or extreme near-sightedness. To mitigate the progression of myopia in children, it is paramount to increase their daily exposure to bright light as well as their time spent outdoors. This is as simple as ensuring children spend adequate time outside during the day. The recommendation is two hours of outdoor activity everyday. However, as children spend most of their day at school while parents attend work, it can be challenging for parents to keep track of their child's time spent outdoors.

Our product, the Neox Sens, aims to solve this problem by bridging the gap between children and their parents. The Neox Sens is a simple wearable device that a child can wear to estimate their time spent outdoors. The Neox Sens records all data locally to avoid ethical issues regarding information sharing around children. Parents can use a mobile application which can communicate with the Neox Sens via Bluetooth to access their child's data. Parents can then choose to upload that data to a cloud database that researchers or clinicians can utilise to aid them in studying Myopia.
"""),
            _buildHeading("Background"),

            _buildText("""
Myopia occurs when the light entering the eyes is focused prior to reaching the retina, leading to blurred long-distance vision. Myopia begins in early childhood between the ages 8 to 12. The eyeball elongates during the ocular development process during the teenage years. This increases the axial length out of proportion, causing the most common type of myopia: axial myopia (Recko & Stahl, 2015). In New Zealand, 29.8% of patients visiting aged 18 years and younger are diagnosed with myopia.  

Early intervention is important to slow the progression of myopia. Although the blurred vision of myopia can be corrected with glasses, the abnormal eye structure leads to higher risk of severe eye conditions later in life. These include open-angle glaucoma, cataract, retinal detachment, and retinal tears. Furthermore, myopic macular degeneration has been noted as the most frequent cause of blindness in cross-sectional studies conducted in Taiwan, Hong Kong, Japan, and the Netherlands. 

There are several clinical interventions in New Zealand for myopia, including atropine eye drops, corrective hard lens, and red light therapy. However, these solutions are expensive and impractical. Atropine eye drops have side effects such as irritation and light sensitivity. Contact lenses increase the risk of eye infections. Red light therapy is a novel treatment, and the long term safety issues have not been properly explored. Furthermore, the clinical interventions require a high level of compliance from the child. Considering that the onset of myopia begins at a young age, the best interventions are through environmental and behavioural modifications. Several non-genetic factors have been identified as accelerating the progression of myopia, such as reduced outdoor light exposure, increased near work, and reduced physical activity. Among these, outdoor light exposure has been identified as the most significant mitigating factor.

Outdoor activity is the greatest measure in reducing the risk of developing myopia and slowing the progression in children. Each additional hour spent outdoors per week reduced the probability of myopia by 2%. Although the exact biological mechanism is unknown, the most credited hypothesis is that the protective effect of outdoor exposure comes from the light intensity. When the eyes are stimulated by bright light, the eyes increase the level of retinal dopamine and activation of dopamine receptors. Dopamine limits axial myopia development by inhibiting the eyes from elongating. The chromatic composition of sunlight is also hypothesised as slowing the progression of myopia. Sunlight has a high ratio of blue light, which is focused closer to the lens. The eyes develop hyperopic refraction, which counters myopia.The synthesis of vitamin D through sunlight is another contributing factor. Vitamin D adjusts the smooth ciliary muscle, which regulates the length and refractive degree of the eye. Outdoor activity is important as sunlight reduces the progression of myopia through light intensity, chromatic composition, and vitamin D synthesis.

Although the recommendation is two hours of outdoor activity everyday, it is difficult to utilise the intervention in practice for young children. Primary children have less structured hours at school, which makes it difficult to accurately quantify the amount of time spent outdoors. It is also impossible to measure the time the children spent outdoors in between classes from recall alone. More objective measures must be used. 

Several mobile apps use the GPS and cellular strength sensors in the mobile phone to detect if the person is indoors or outdoors. However, this is impracticable for young children who are likely to not have mobile phones. Even when the child carries the mobile phone, the accuracy decreases when the phone is put inside the bag or in the pocket. Privacy is also a concern. It is not safe for children to be tracked with a device that has wireless connection. Wearable detectors have been developed overseas, such as the HOBO Pendant and the Actiwatch. However, these solutions are not for the purpose of quantifying outdoor time. The HOBO Pendant is used for temperature and light monitoring applications, and the Actiwatch is used to monitor sleep patterns. 

Therefore, we have created the the Neox Sens, a device to detect indoors or outdoor environments. Our project solves the problem of parents being unable to track how much time the child has spent outdoors.
"""),
          ],
        ),
      ),
    );           
  }
}
